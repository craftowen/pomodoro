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
        send(title: "포모도로 완료!", body: "휴식 시간입니다 ☕", soundEnabled: soundEnabled)
    }

    static func sendShortBreakComplete(soundEnabled: Bool) {
        send(title: "휴식 끝!", body: "다음 포모도로를 시작하세요", soundEnabled: soundEnabled)
    }

    static func sendLongBreakComplete(soundEnabled: Bool) {
        send(title: "긴 휴식 끝!", body: "새로운 사이클을 시작하세요", soundEnabled: soundEnabled)
    }
}
