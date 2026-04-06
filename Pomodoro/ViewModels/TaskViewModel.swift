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

    func toggleSelection(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        if tasks[index].isSelected {
            tasks[index].isSelected = false
        } else {
            // Deselect all others
            for i in tasks.indices {
                tasks[i].isSelected = false
            }
            tasks[index].isSelected = true
        }
        saveTasks()
    }

    func mergeCalendarEvents(_ events: [TaskItem]) {
        tasks.removeAll { $0.source == .googleCalendar || $0.source == .systemCalendar }
        tasks.append(contentsOf: events)
        saveTasks()
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
