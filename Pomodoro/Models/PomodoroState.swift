import Foundation

enum TimerPhase: String, Codable {
    case idle
    case focus
    case shortBreak
    case longBreak
}

enum SessionStatus: String, Codable {
    case completed
    case cancelled
}

enum TimerAction {
    case start
    case pause
    case resume
    case reset
    case skip
    case complete
}

@MainActor
@Observable
final class PomodoroState {
    var phase: TimerPhase = .idle
    var remainingSeconds: Int = 0
    var isPaused: Bool = false
    var cycleCount: Int = 0
    var currentTaskId: UUID?
    var totalSeconds: Int = 0

    var isRunning: Bool {
        phase != .idle && !isPaused
    }

    var isActive: Bool {
        phase != .idle
    }

    var displayTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }

    func transition(action: TimerAction, settings: UserSettings) {
        switch action {
        case .start:
            guard phase == .idle else { return }
            phase = .focus
            totalSeconds = settings.focusDuration
            remainingSeconds = settings.focusDuration
            isPaused = false

        case .pause:
            guard isRunning else { return }
            isPaused = true

        case .resume:
            guard isPaused else { return }
            isPaused = false

        case .reset:
            phase = .idle
            totalSeconds = 0
            remainingSeconds = 0
            isPaused = false

        case .skip:
            guard phase == .shortBreak || phase == .longBreak else { return }
            let wasLongBreak = phase == .longBreak
            phase = .idle
            totalSeconds = 0
            remainingSeconds = 0
            isPaused = false
            if wasLongBreak {
                cycleCount = 0
            }

        case .complete:
            switch phase {
            case .focus:
                cycleCount += 1
                if cycleCount >= 4 {
                    phase = .longBreak
                    totalSeconds = settings.longBreakDuration
                    remainingSeconds = settings.longBreakDuration
                } else {
                    phase = .shortBreak
                    totalSeconds = settings.shortBreakDuration
                    remainingSeconds = settings.shortBreakDuration
                }
                isPaused = false

            case .shortBreak:
                if settings.autoStartNextPomodoro {
                    phase = .focus
                    totalSeconds = settings.focusDuration
                    remainingSeconds = settings.focusDuration
                    isPaused = false
                } else {
                    phase = .idle
                    totalSeconds = 0
                    remainingSeconds = 0
                }

            case .longBreak:
                cycleCount = 0
                phase = .idle
                totalSeconds = 0
                remainingSeconds = 0

            case .idle:
                break
            }
        }
    }
}
