import Foundation

@MainActor
@Observable
final class TaskViewModel {
    var tasks: [TaskItem] = []

    var selectedTask: TaskItem? {
        tasks.first(where: { $0.isSelected })
    }

    var todayTasks: [TaskItem] {
        let sorted = tasks.sorted { a, b in
            // All-day events first, then by scheduled time, then by creation time
            if a.isAllDay != b.isAllDay { return a.isAllDay }
            if let aTime = a.scheduledTime, let bTime = b.scheduledTime {
                return aTime < bTime
            }
            if a.scheduledTime != nil { return true }
            if b.scheduledTime != nil { return false }
            return a.createdAt < b.createdAt
        }
        return sorted
    }

    init() {
        loadTasks()
    }

    func addTask(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let task = TaskItem(title: title.trimmingCharacters(in: .whitespaces))
        tasks.append(task)
        saveTasks()
    }

    func deleteTask(_ task: TaskItem) {
        guard task.source == .manual else { return }
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    func toggleCompletion(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        if tasks[index].isCompleted && tasks[index].isSelected {
            tasks[index].isSelected = false
        }
        saveTasks()
    }

    func selectTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        guard !tasks[index].isSelected else { return }

        for i in tasks.indices {
            tasks[i].isSelected = false
        }
        tasks[index].isSelected = true
        saveTasks()
    }

    func mergeCalendarEvents(_ events: [TaskItem]) {
        tasks = Self.mergedCalendarTasks(existing: tasks, events: events)
        saveTasks()
    }

    /// 캘린더 동기화 결과를 기존 목록과 병합한다.
    /// 같은 `calendarEventId`를 가진 항목은 로컬 상태(완료/선택/id/생성시각)를 보존하고
    /// 캘린더 측 메타데이터(제목·예정시각·종일여부)만 최신으로 갱신한다.
    /// 교체 방식이던 과거 구현은 매 동기화마다 완료 체크가 풀리는 버그를 유발했다.
    nonisolated static func mergedCalendarTasks(
        existing: [TaskItem],
        events: [TaskItem]
    ) -> [TaskItem] {
        let manualTasks = existing.filter { $0.source == .manual }

        let existingByEventId = Dictionary(
            existing
                .filter { $0.source == .googleCalendar || $0.source == .systemCalendar }
                .compactMap { task -> (String, TaskItem)? in
                    guard let eventId = task.calendarEventId else { return nil }
                    return (eventId, task)
                },
            uniquingKeysWith: { first, _ in first }
        )

        let calendarTasks = events.map { event -> TaskItem in
            guard let eventId = event.calendarEventId,
                  var preserved = existingByEventId[eventId] else {
                return event
            }
            // 로컬 상태(isCompleted/isSelected/id/createdAt)는 preserved에 그대로 유지,
            // 캘린더에서 바뀔 수 있는 필드만 새 이벤트 값으로 갱신.
            preserved.title = event.title
            preserved.scheduledTime = event.scheduledTime
            preserved.isAllDay = event.isAllDay
            return preserved
        }

        return manualTasks + calendarTasks
    }

    private func saveTasks() {
        let todayKey = taskFileKey()
        StorageService.save(tasks, to: todayKey)
    }

    private func loadTasks() {
        let todayKey = taskFileKey()
        tasks = StorageService.load([TaskItem].self, from: todayKey) ?? []
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func taskFileKey() -> String {
        "tasks-\(Self.dayFormatter.string(from: Date())).json"
    }
}
