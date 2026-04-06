import SwiftUI
import AppKit
import KeyboardShortcuts

@main
struct PomodoroApp: App {
    @State private var timerVM = TimerViewModel()
    @State private var taskVM = TaskViewModel()
    @State private var updaterService = UpdaterService()
    var body: some Scene {
        MenuBarExtra {
            PopoverView(timerVM: timerVM, taskVM: taskVM, updaterService: updaterService)
                .frame(width: 320, height: 420)
                .onChange(of: taskVM.selectedTask?.id) { _, newId in
                    timerVM.state.currentTaskId = newId
                }
        } label: {
            if timerVM.state.isActive {
                Image(nsImage: StatusItemConfigurator.makeStatusBarImage(
                    taskName: menuBarTaskName,
                    time: menuBarTime,
                    progress: timerVM.state.progress,
                    phase: timerVM.state.phase,
                    isPaused: timerVM.state.isPaused
                ))
            } else {
                Text(menuBarTitle)
            }
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarTitle: String {
        if let task = taskVM.selectedTask {
            return "🍅 \(task.truncatedTitle)"
        }
        return "🍅"
    }

    private var menuBarTaskName: String? {
        switch timerVM.state.phase {
        case .focus:
            let prefix = timerVM.state.isPaused ? "⏸ " : ""
            if let task = taskVM.selectedTask {
                return "\(prefix)\(task.truncatedTitle)"
            }
            return timerVM.state.isPaused ? "⏸" : nil
        case .shortBreak, .longBreak:
            return "☕"
        case .idle:
            return nil
        }
    }

    private var menuBarTime: String {
        timerVM.state.displayTime
    }
}

enum StatusItemConfigurator {
    /// 원형 프로그레스 링 + 태스크명(흰색) + 시간(accent) 렌더링
    static func makeStatusBarImage(taskName: String?, time: String, progress: Double, phase: TimerPhase, isPaused: Bool) -> NSImage {
        let ringSize: CGFloat = 16
        let lineWidth: CGFloat = 2.5
        let ringTextGap: CGFloat = 4
        let scale: CGFloat = 2.0

        // 시간 색상: accent color
        let timeColor: NSColor = switch phase {
        case .focus: NSColor(srgbRed: 1.0, green: 0.50, blue: 0.50, alpha: 1)
        case .shortBreak, .longBreak: NSColor(srgbRed: 0.50, green: 0.88, blue: 0.55, alpha: 1)
        case .idle: NSColor.white
        }
        let font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)

        // 태스크명 (흰색) + 시간 (accent) 조합
        let combined = NSMutableAttributedString()
        if let name = taskName {
            combined.append(NSAttributedString(string: "\(name) ", attributes: [
                .font: font,
                .foregroundColor: NSColor.white.withAlphaComponent(0.85)
            ]))
        }
        combined.append(NSAttributedString(string: time, attributes: [
            .font: font,
            .foregroundColor: timeColor
        ]))

        let textSize = combined.size()
        let totalWidth = ringSize + ringTextGap + textSize.width
        let totalHeight = max(ringSize, textSize.height)

        let pixelW = Int(totalWidth * scale)
        let pixelH = Int(totalHeight * scale)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil, width: pixelW, height: pixelH,
            bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return NSImage() }

        ctx.scaleBy(x: scale, y: scale)

        // --- 원형 프로그레스 링 ---
        let ringCenterY = totalHeight / 2
        let ringCenter = CGPoint(x: ringSize / 2, y: ringCenterY)
        let radius = (ringSize - lineWidth) / 2

        // 배경 트랙
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(CGColor(gray: 1.0, alpha: 0.2))
        ctx.addArc(center: ringCenter, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        // 프로그레스 아크
        if progress > 0.005 {
            let startAngle = CGFloat.pi / 2
            let endAngle = startAngle - CGFloat(progress) * 2 * .pi
            ctx.setLineCap(.round)
            let arcColor: CGColor = switch phase {
            case .focus: CGColor(srgbRed: 1.0, green: 0.40, blue: 0.40, alpha: 1)
            case .shortBreak, .longBreak: CGColor(srgbRed: 0.40, green: 0.85, blue: 0.45, alpha: 1)
            case .idle: CGColor(gray: 0.5, alpha: 0.3)
            }
            ctx.setStrokeColor(arcColor)
            ctx.addArc(center: ringCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            ctx.strokePath()
        }

        // --- 텍스트 ---
        let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsCtx
        let textX = ringSize + ringTextGap
        let textY = (totalHeight - textSize.height) / 2
        combined.draw(at: NSPoint(x: textX, y: textY))
        NSGraphicsContext.restoreGraphicsState()

        guard let cgImage = ctx.makeImage() else { return NSImage() }
        let image = NSImage(cgImage: cgImage, size: NSSize(width: totalWidth, height: totalHeight))
        image.isTemplate = false
        return image
    }
}
