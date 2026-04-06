import SwiftUI

enum PopoverTab {
    case main
    case settings
}

struct PopoverView: View {
    let timerVM: TimerViewModel
    let taskVM: TaskViewModel
    @State private var activeTab: PopoverTab = .main

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch activeTab {
                case .main:
                    mainContent
                        .transition(.move(edge: .leading).combined(with: .opacity))
                case .settings:
                    settingsContent
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: activeTab)

            Divider()

            HStack {
                if activeTab == .main {
                    Button(action: { activeTab = .settings }) {
                        Image(systemName: "gear")
                            .font(.system(size: 11))
                            .foregroundStyle(.quaternary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "settings"))
                } else {
                    Button(action: { activeTab = .main }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 9, weight: .semibold))
                            Text(String(localized: "back"))
                                .font(.system(size: 10, design: .rounded))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Text(String(localized: "quit"))
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.quaternary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "quit"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            TimerView(timerVM: timerVM, currentTaskName: taskVM.selectedTask?.title)

            Divider()

            TaskListView(taskVM: taskVM)
        }
    }

    private var settingsContent: some View {
        InlineSettingsView(timerVM: timerVM, taskVM: taskVM)
    }
}
