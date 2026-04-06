import SwiftUI

enum PopoverTab {
    case main
    case settings
}

struct PopoverView: View {
    let timerVM: TimerViewModel
    let taskVM: TaskViewModel
    let updaterService: UpdaterService
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
            .frame(maxHeight: .infinity, alignment: .top)
            .animation(.easeInOut(duration: 0.25), value: activeTab)

            Divider()

            HStack(spacing: 0) {
                tabButton(
                    icon: "timer",
                    title: String(localized: "tab.timer"),
                    tab: .main
                )

                tabButton(
                    icon: "gear",
                    title: String(localized: "tab.settings"),
                    tab: .settings
                )

                Spacer()

                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Text(String(localized: "quit"))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "quit"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }

    private func tabButton(icon: String, title: String, tab: PopoverTab) -> some View {
        let isActive = activeTab == tab
        return Button(action: { activeTab = tab }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 11, weight: isActive ? .medium : .regular, design: .rounded))
            }
            .foregroundStyle(isActive ? .primary : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isActive ? Color.primary.opacity(0.06) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            TimerView(timerVM: timerVM, currentTaskName: taskVM.selectedTask?.title)

            Divider()

            TaskListView(taskVM: taskVM)
        }
    }

    private var settingsContent: some View {
        InlineSettingsView(timerVM: timerVM, taskVM: taskVM, updaterService: updaterService)
    }
}
