import Foundation
import EventKit
import AppKit

struct CalendarInfo: Identifiable {
    let id: String
    let title: String
    let color: CGColor?
}

@MainActor
@Observable
final class CalendarViewModel {
    var isAuthorized: Bool = false
    var calendars: [CalendarInfo] = []
    var errorMessage: String?
    var awaitingPermission: Bool = false

    private let service = CalendarService.shared
    private let settings = UserSettings.shared

    private var midnightTimer: Timer?
    private var pollingTimer: Timer?
    private var wakeObserver: NSObjectProtocol?
    private var storeChangedObserver: NSObjectProtocol?
    private var debounceTask: Task<Void, Never>?
    private var lastSyncDay: Date?
    private weak var boundTaskVM: TaskViewModel?

    /// 안전망 폴링 기준 간격(초). 실제 발화는 ±25% 지터로 분산.
    /// EKEventStoreChanged 알림이 주 갱신 경로이며, 폴링은 놓친 변경 대비 보조 수단.
    nonisolated private static let pollingBaseInterval: TimeInterval = 15 * 60

    init() {
        isAuthorized = service.isAuthorized
    }

    nonisolated static func nextMidnight(after date: Date, calendar: Calendar = .current) -> Date {
        let startOfToday = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? date.addingTimeInterval(86400)
    }

    /// 폴링 간격에 ±(jitterFraction) 지터를 적용한다.
    /// random(0...1)을 주입받아 결정적으로 계산 — Google 권장대로 트래픽 분산.
    /// random=0 → base-jitter, random=0.5 → base, random=1 → base+jitter.
    nonisolated static func pollingInterval(
        base: TimeInterval = pollingBaseInterval,
        jitterFraction: Double = 0.25,
        random: Double
    ) -> TimeInterval {
        let clamped = min(max(random, 0), 1)
        let jitter = base * jitterFraction
        return base - jitter + (2 * jitter * clamped)
    }

    func requestAccess() async {
        let status = EKEventStore.authorizationStatus(for: .event)

        if status == .notDetermined {
            // First time: show system dialog
            isAuthorized = await service.requestAccess()
            if isAuthorized {
                errorMessage = nil
                loadCalendars()
            } else {
                errorMessage = String(localized: "settings.calendarDenied")
            }
        } else {
            // Previously denied or restricted: open System Settings
            awaitingPermission = true
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    func refreshAuthStatus() {
        let wasAwaiting = awaitingPermission
        isAuthorized = service.isAuthorized
        if isAuthorized {
            awaitingPermission = false
            errorMessage = nil
            service.refreshStore()
            loadCalendars()
        } else if wasAwaiting {
            awaitingPermission = false
            calendars = []
            errorMessage = String(localized: "settings.calendarDenied")
        } else {
            calendars = []
        }
    }

    func loadCalendars() {
        calendars = service.availableCalendars().map {
            CalendarInfo(id: $0.calendarIdentifier, title: $0.title, color: $0.cgColor)
        }
    }

    func syncEvents(into taskVM: TaskViewModel) {
        let selectedIds = settings.selectedCalendarIds
        guard !selectedIds.isEmpty else {
            taskVM.mergeCalendarEvents([])
            return
        }

        let events = service.fetchTodayEvents(calendarIds: selectedIds)
        taskVM.mergeCalendarEvents(events)
    }

    func toggleCalendar(_ calendarId: String) {
        if settings.selectedCalendarIds.contains(calendarId) {
            settings.selectedCalendarIds.removeAll { $0 == calendarId }
        } else {
            settings.selectedCalendarIds.append(calendarId)
        }
    }

    func startAutoRefresh(taskVM: TaskViewModel) {
        stopAutoRefresh()
        boundTaskVM = taskVM

        performAutoSync()
        scheduleNextMidnight()
        schedulePolling()

        // 주 갱신 경로: 캘린더 데이터가 바뀌면(Google 등 계정 동기화 포함) 시스템이 즉시 통지.
        storeChangedObserver = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleStoreChanged()
            }
        }

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleWake()
            }
        }
    }

    func stopAutoRefresh() {
        midnightTimer?.invalidate()
        midnightTimer = nil
        pollingTimer?.invalidate()
        pollingTimer = nil
        debounceTask?.cancel()
        debounceTask = nil
        if let observer = wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            wakeObserver = nil
        }
        if let observer = storeChangedObserver {
            NotificationCenter.default.removeObserver(observer)
            storeChangedObserver = nil
        }
        boundTaskVM = nil
    }

    /// EKEventStoreChanged는 한 번의 변경에도 연속 발생할 수 있어 1초 디바운스 후 한 번만 동기화.
    private func handleStoreChanged() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1))
            guard let self, !Task.isCancelled else { return }
            self.service.refreshStore()
            self.performAutoSync()
        }
    }

    private func schedulePolling() {
        pollingTimer?.invalidate()
        let interval = Self.pollingInterval(random: Double.random(in: 0...1))
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handlePolling()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        pollingTimer = timer
    }

    private func handlePolling() {
        service.refreshStore()
        performAutoSync()
        schedulePolling() // 매 주기 새 지터로 재스케줄
    }

    private func scheduleNextMidnight() {
        midnightTimer?.invalidate()
        let now = Date()
        let fireDate = Self.nextMidnight(after: now)
        let interval = max(fireDate.timeIntervalSince(now), 1)
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleMidnight()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        midnightTimer = timer
    }

    private func handleMidnight() {
        performAutoSync()
        scheduleNextMidnight()
    }

    private func handleWake() {
        let today = Calendar.current.startOfDay(for: Date())
        if lastSyncDay != today {
            performAutoSync()
            scheduleNextMidnight()
        }
    }

    private func performAutoSync() {
        guard let taskVM = boundTaskVM else { return }
        syncEvents(into: taskVM)
        lastSyncDay = Calendar.current.startOfDay(for: Date())
    }
}
