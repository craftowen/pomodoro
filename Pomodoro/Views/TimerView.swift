import SwiftUI

struct TimerView: View {
    let timerVM: TimerViewModel

    var body: some View {
        VStack(spacing: 8) {
            if timerVM.state.isActive {
                Text(timerVM.state.displayTime)
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                    .foregroundStyle(phaseColor)

                HStack(spacing: 16) {
                    // Pause / Resume
                    Button(action: { timerVM.toggleStartPause() }) {
                        Image(systemName: timerVM.state.isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)

                    // Reset
                    Button(action: { timerVM.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)

                    // Skip (only during breaks)
                    if timerVM.state.phase == .shortBreak || timerVM.state.phase == .longBreak {
                        Button(action: { timerVM.skip() }) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text(phaseLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("🍅")
                    .font(.system(size: 36))
                Text("준비")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("시작") {
                    timerVM.toggleStartPause()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
        }
        .padding(.vertical, 12)
    }

    private var phaseColor: Color {
        switch timerVM.state.phase {
        case .focus: .red
        case .shortBreak, .longBreak: .green
        case .idle: .primary
        }
    }

    private var phaseLabel: String {
        switch timerVM.state.phase {
        case .focus:
            return "포모도로 \(timerVM.state.cycleCount + 1)/4"
        case .shortBreak:
            return "짧은 휴식"
        case .longBreak:
            return "긴 휴식"
        case .idle:
            return ""
        }
    }
}
