import Foundation
import AppKit

struct NotificationService {
    static func requestPermission() {
        // Use NSUserNotificationCenter for non-sandboxed apps
        // Permission is implicit for menu bar apps
    }

    static func send(title: String, body: String, soundEnabled: Bool) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        if soundEnabled {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        NSUserNotificationCenter.default.deliver(notification)
    }

    static func sendFocusComplete(soundEnabled: Bool) {
        send(
            title: String(localized: "notification.focusComplete.title"),
            body: String(localized: "notification.focusComplete.body"),
            soundEnabled: soundEnabled
        )
    }

    static func sendShortBreakComplete(soundEnabled: Bool) {
        send(
            title: String(localized: "notification.shortBreakComplete.title"),
            body: String(localized: "notification.shortBreakComplete.body"),
            soundEnabled: soundEnabled
        )
    }

    static func sendLongBreakComplete(soundEnabled: Bool) {
        send(
            title: String(localized: "notification.longBreakComplete.title"),
            body: String(localized: "notification.longBreakComplete.body"),
            soundEnabled: soundEnabled
        )
    }
}
