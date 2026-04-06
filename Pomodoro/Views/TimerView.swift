import SwiftUI

struct TimerView: View {
    let timerVM: TimerViewModel
    var currentTaskName: String?

    var body: some View {
        HStack(spacing: 14) {
            timerRing
                .frame(width: 56, height: 56)

            if timerVM.state.isActive {
                activeInfo
            } else {
                idleInfo
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Color(nsColor: .systemGray).opacity(0.2), lineWidth: 1.5)

            if timerVM.state.isActive {
                Circle()
                    .trim(from: 0, to: timerVM.state.progress)
                    .stroke(
                        phaseColor,
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: timerVM.state.progress)
                    .opacity(timerVM.state.isPaused ? 0.5 : 1.0)
                    .animation(
                        timerVM.state.isPaused
                            ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                            : .default,
                        value: timerVM.state.isPaused
                    )
            }

            if timerVM.state.isActive {
                Text(timerVM.state.displayTime)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(.primary)
            } else {
                Text("🍅")
                    .font(.system(size: 20))
            }
        }
    }

    private var activeInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            if timerVM.state.phase == .focus, let name = currentTaskName {
                Text(name)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            } else if timerVM.state.phase == .shortBreak || timerVM.state.phase == .longBreak {
                Text(breakLabel)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(phaseColor)
            }

            Text(phaseSubtitle)
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                if timerVM.state.phase == .focus {
                    Button(action: { timerVM.toggleStartPause() }) {
                        Image(systemName: timerVM.state.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(timerVM.state.isPaused ? "재개" : "일시정지")

                    Button(action: { timerVM.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("리셋")
                } else {
                    Button(action: { timerVM.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("리셋")

                    Button(action: { timerVM.skip() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("건너뛰기")
                }
            }
            .padding(.top, 4)
        }
    }

    private var idleInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("준비")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Button(action: { timerVM.toggleStartPause() }) {
                Text("시작")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.pomodoroFocus)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("포모도로 시작")
        }
    }

    private var phaseColor: Color {
        switch timerVM.state.phase {
        case .focus: Color.pomodoroFocus
        case .shortBreak, .longBreak: Color.pomodoroBreak
        case .idle: .secondary
        }
    }

    private var breakLabel: String {
        switch timerVM.state.phase {
        case .shortBreak: "☕ 짧은 휴식"
        case .longBreak: "☕ 긴 휴식"
        default: ""
        }
    }

    private var phaseSubtitle: String {
        switch timerVM.state.phase {
        case .focus:
            "포모도로 \(timerVM.state.cycleCount + 1)/4"
        case .shortBreak:
            "다음: 포모도로 \(timerVM.state.cycleCount + 1)/4"
        case .longBreak:
            "다음: 새 사이클"
        case .idle:
            ""
        }
    }
}
