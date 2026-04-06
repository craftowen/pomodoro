import Foundation
import AppKit
import KeyboardShortcuts
import Combine

@MainActor
@Observable
final class TimerViewModel {
    let state = PomodoroState()
    private let settings = UserSettings.shared
    private var timer: Timer?
    private var currentSession: PomodoroSession?
    private var sleepTime: Date?
    private var workspaceObservers: [Any] = []

    init() {
        setupHotkey()
        setupSleepWakeObservers()
        NotificationService.requestPermission()
    }


    // MARK: - Actions

    func toggleStartPause() {
        switch state.phase {
        case .idle:
            startFocus()
        case .focus, .shortBreak, .longBreak:
            if state.isPaused {
                resume()
            } else {
                pause()
            }
        }
    }

    func reset() {
        stopAndCancelSession()
        state.transition(action: .reset, settings: settings)
    }

    func skip() {
        stopAndCancelSession()
        state.transition(action: .skip, settings: settings)
    }

    // MARK: - Private

    private func stopAndCancelSession() {
        timer?.invalidate()
        timer = nil
        if var session = currentSession {
            session.cancel()
            saveSession(session)
        }
        currentSession = nil
    }

    private func startFocus() {
        state.transition(action: .start, settings: settings)
        currentSession = PomodoroSession(
            type: .focus,
            duration: TimeInterval(settings.focusDuration),
            taskId: state.currentTaskId
        )
        startTimer()
    }

    private func pause() {
        state.transition(action: .pause, settings: settings)
        timer?.invalidate()
        timer = nil
    }

    private func resume() {
        state.transition(action: .resume, settings: settings)
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func tick() {
        guard state.isRunning else { return }

        if state.remainingSeconds > 0 {
            state.remainingSeconds -= 1
        }

        if state.remainingSeconds == 0 {
            timerCompleted()
        }
    }

    private func timerCompleted() {
        timer?.invalidate()
        timer = nil

        let completedPhase = state.phase

        if var session = currentSession {
            session.complete()
            saveSession(session)
        }
        currentSession = nil

        switch completedPhase {
        case .focus:
            NotificationService.sendFocusComplete(soundEnabled: settings.soundEnabled)
        case .shortBreak:
            NotificationService.sendShortBreakComplete(soundEnabled: settings.soundEnabled)
        case .longBreak:
            NotificationService.sendLongBreakComplete(soundEnabled: settings.soundEnabled)
        case .idle:
            break
        }

        state.transition(action: .complete, settings: settings)

        if state.phase != .idle {
            let sessionType: PomodoroSession.SessionType = switch state.phase {
            case .focus: .focus
            case .shortBreak: .shortBreak
            case .longBreak: .longBreak
            case .idle: .focus // unreachable
            }
            currentSession = PomodoroSession(
                type: sessionType,
                duration: TimeInterval(state.remainingSeconds),
                taskId: state.currentTaskId
            )
            startTimer()
        }
    }

    private func saveSession(_ session: PomodoroSession) {
        var sessions = StorageService.load([PomodoroSession].self, from: "sessions.json") ?? []
        sessions.append(session)
        StorageService.save(sessions, to: "sessions.json")
    }

    // MARK: - Hotkey (T014)

    private func setupHotkey() {
        KeyboardShortcuts.onKeyUp(for: .toggleTimer) { [weak self] in
            DispatchQueue.main.async {
                self?.toggleStartPause()
            }
        }
    }

    // MARK: - Sleep/Wake (T021)

    private func setupSleepWakeObservers() {
        let sleepObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.sleepTime = Date()
        }

        let wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleWake()
        }

        workspaceObservers = [sleepObserver, wakeObserver]
    }

    private func handleWake() {
        guard let sleepTime, state.isActive else {
            self.sleepTime = nil
            return
        }

        let elapsedWhileSleeping = Int(Date().timeIntervalSince(sleepTime))
        self.sleepTime = nil

        if state.isPaused { return }

        if elapsedWhileSleeping >= state.remainingSeconds {
            state.remainingSeconds = 0
            timerCompleted()
        } else {
            state.remainingSeconds -= elapsedWhileSleeping
            startTimer()
        }
    }
}
