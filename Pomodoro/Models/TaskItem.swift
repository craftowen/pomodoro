import Foundation

enum TaskSource: String, Codable {
    case manual
    case googleCalendar // legacy
    case systemCalendar
}

struct TaskItem: Codable, Identifiable {
    let id: UUID
    var title: String
    let source: TaskSource
    var calendarEventId: String?
    var scheduledTime: Date?
    var isAllDay: Bool
    var isCompleted: Bool
    var isSelected: Bool
    let createdAt: Date

    init(
        title: String,
        source: TaskSource = .manual,
        calendarEventId: String? = nil,
        scheduledTime: Date? = nil,
        isAllDay: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.source = source
        self.calendarEventId = calendarEventId
        self.scheduledTime = scheduledTime
        self.isAllDay = isAllDay
        self.isCompleted = false
        self.isSelected = false
        self.createdAt = Date()
    }

    var truncatedTitle: String {
        if title.count > 20 {
            return String(title.prefix(20)) + "..."
        }
        return title
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var timeLabel: String? {
        guard let time = scheduledTime, !isAllDay else { return nil }
        return Self.timeFormatter.string(from: time)
    }
}
