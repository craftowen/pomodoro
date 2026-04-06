import Foundation

struct PomodoroSession: Codable, Identifiable {
    let id: UUID
    let type: SessionType
    let startedAt: Date
    var endedAt: Date?
    let duration: TimeInterval
    var taskId: UUID?
    var status: SessionStatus

    enum SessionType: String, Codable {
        case focus
        case shortBreak
        case longBreak
    }

    init(
        type: SessionType,
        duration: TimeInterval,
        taskId: UUID? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.startedAt = Date()
        self.endedAt = nil
        self.duration = duration
        self.taskId = taskId
        self.status = .completed
    }

    mutating func complete() {
        endedAt = Date()
        status = .completed
    }

    mutating func cancel() {
        endedAt = Date()
        status = .cancelled
    }
}
