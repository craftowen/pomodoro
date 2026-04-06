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
            switch activeTab {
            case .main:
                mainContent
            case .settings:
                settingsContent
            }

            Divider()

            HStack {
                if activeTab == .main {
                    Button {
                        activeTab = .settings
                    } label: {
                        Label("설정", systemImage: "gear")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        activeTab = .main
                    } label: {
                        Label("돌아가기", systemImage: "chevron.left")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button("종료") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            TimerView(timerVM: timerVM)
                .padding(.horizontal)

            Divider()

            TaskListView(taskVM: taskVM)
        }
    }

    private var settingsContent: some View {
        InlineSettingsView(timerVM: timerVM, taskVM: taskVM)
    }
}
