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

    init() {
        isAuthorized = service.isAuthorized
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
}
