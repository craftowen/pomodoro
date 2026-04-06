import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleTimer = Self("toggleTimer", default: .init(.p, modifiers: [.command, .shift]))
}

@MainActor
@Observable
final class UserSettings {
    static let shared = UserSettings()

    private enum Keys {
        static let focusDuration = "focusDuration"
        static let shortBreakDuration = "shortBreakDuration"
        static let longBreakDuration = "longBreakDuration"
        static let autoStartNextPomodoro = "autoStartNextPomodoro"
        static let launchAtLogin = "launchAtLogin"
        static let selectedCalendarIds = "selectedCalendarIds"
        static let soundEnabled = "soundEnabled"
    }

    var focusDuration: Int {
        didSet { UserDefaults.standard.set(focusDuration, forKey: Keys.focusDuration) }
    }

    var shortBreakDuration: Int {
        didSet { UserDefaults.standard.set(shortBreakDuration, forKey: Keys.shortBreakDuration) }
    }

    var longBreakDuration: Int {
        didSet { UserDefaults.standard.set(longBreakDuration, forKey: Keys.longBreakDuration) }
    }

    var autoStartNextPomodoro: Bool {
        didSet { UserDefaults.standard.set(autoStartNextPomodoro, forKey: Keys.autoStartNextPomodoro) }
    }

    var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    var selectedCalendarIds: [String] {
        didSet { UserDefaults.standard.set(selectedCalendarIds, forKey: Keys.selectedCalendarIds) }
    }

    var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled) }
    }

    var focusDurationMinutes: Int {
        get { focusDuration / 60 }
        set { focusDuration = newValue * 60 }
    }

    var shortBreakDurationMinutes: Int {
        get { shortBreakDuration / 60 }
        set { shortBreakDuration = newValue * 60 }
    }

    var longBreakDurationMinutes: Int {
        get { longBreakDuration / 60 }
        set { longBreakDuration = newValue * 60 }
    }

    private init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            Keys.focusDuration: 1500,
            Keys.shortBreakDuration: 300,
            Keys.longBreakDuration: 900,
            Keys.autoStartNextPomodoro: false,
            Keys.launchAtLogin: false,
            Keys.soundEnabled: true
        ])

        self.focusDuration = defaults.integer(forKey: Keys.focusDuration)
        self.shortBreakDuration = defaults.integer(forKey: Keys.shortBreakDuration)
        self.longBreakDuration = defaults.integer(forKey: Keys.longBreakDuration)
        self.autoStartNextPomodoro = defaults.bool(forKey: Keys.autoStartNextPomodoro)
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.selectedCalendarIds = defaults.stringArray(forKey: Keys.selectedCalendarIds) ?? []
        self.soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
    }
}
