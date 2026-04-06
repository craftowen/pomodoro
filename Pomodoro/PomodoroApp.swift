import SwiftUI
import AppKit
import KeyboardShortcuts

@main
struct PomodoroApp: App {
    @State private var timerVM = TimerViewModel()
    @State private var taskVM = TaskViewModel()
    @State private var statusItemConfigurator = StatusItemConfigurator()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(timerVM: timerVM, taskVM: taskVM)
                .frame(width: 280, height: 400)
                .onChange(of: taskVM.selectedTask?.id) { _, newId in
                    timerVM.state.currentTaskId = newId
                }
        } label: {
            Text(menuBarTitle)
                .onChange(of: timerVM.state.remainingSeconds) { _, _ in
                    statusItemConfigurator.updateImage(
                        isActive: timerVM.state.isActive,
                        progress: timerVM.state.progress,
                        phase: timerVM.state.phase
                    )
                }
                .onChange(of: timerVM.state.phase) { _, _ in
                    statusItemConfigurator.updateImage(
                        isActive: timerVM.state.isActive,
                        progress: timerVM.state.progress,
                        phase: timerVM.state.phase
                    )
                }
                .onAppear {
                    statusItemConfigurator.updateImage(
                        isActive: timerVM.state.isActive,
                        progress: timerVM.state.progress,
                        phase: timerVM.state.phase
                    )
                }
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarTitle: String {
        let state = timerVM.state

        switch state.phase {
        case .idle:
            if let task = taskVM.selectedTask {
                return "🍅 \(task.truncatedTitle)"
            }
            return "🍅"

        case .focus:
            let prefix = state.isPaused ? "⏸ " : ""
            if let task = taskVM.selectedTask {
                return "\(prefix)\(task.truncatedTitle) \(state.displayTime)"
            }
            return "\(prefix)\(state.displayTime)"

        case .shortBreak, .longBreak:
            return "☕ \(state.displayTime)"
        }
    }
}

@MainActor
final class StatusItemConfigurator {
    private weak var button: NSStatusBarButton?

    func updateImage(isActive: Bool, progress: Double, phase: TimerPhase) {
        let btn = findButton()
        if isActive {
            btn?.image = makeProgressImage(progress: progress, phase: phase)
            btn?.imagePosition = .imageLeading
        } else {
            btn?.image = nil
        }
    }

    private func findButton() -> NSStatusBarButton? {
        if let b = button { return b }
        for window in NSApp.windows {
            if let btn = searchForButton(in: window.contentView) {
                button = btn
                return btn
            }
        }
        return nil
    }

    private func searchForButton(in view: NSView?) -> NSStatusBarButton? {
        guard let view else { return nil }
        if let btn = view as? NSStatusBarButton { return btn }
        for sub in view.subviews {
            if let btn = searchForButton(in: sub) { return btn }
        }
        return nil
    }

    private func makeProgressImage(progress: Double, phase: TimerPhase) -> NSImage {
        let size: CGFloat = 16
        let lineWidth: CGFloat = 2.0
        let scale: CGFloat = 2.0
        let pixelSize = Int(size * scale)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil, width: pixelSize, height: pixelSize,
            bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return NSImage() }

        ctx.scaleBy(x: scale, y: scale)

        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = (size - lineWidth) / 2

        // Background track
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(CGColor(gray: 0.5, alpha: 0.35))
        ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        // Progress arc
        if progress > 0.005 {
            let startAngle = CGFloat.pi / 2
            let endAngle = startAngle - CGFloat(progress) * 2 * .pi
            ctx.setLineCap(.round)
            let color: CGColor = switch phase {
            case .focus: CGColor(srgbRed: 1, green: 0.23, blue: 0.19, alpha: 1)
            case .shortBreak, .longBreak: CGColor(srgbRed: 0.2, green: 0.78, blue: 0.35, alpha: 1)
            case .idle: CGColor(gray: 0.5, alpha: 0.35)
            }
            ctx.setStrokeColor(color)
            ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            ctx.strokePath()
        }

        guard let cgImage = ctx.makeImage() else { return NSImage() }
        let image = NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
        image.isTemplate = false
        return image
    }
}
