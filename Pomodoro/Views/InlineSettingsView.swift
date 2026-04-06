import SwiftUI
import KeyboardShortcuts
import ServiceManagement

struct InlineSettingsView: View {
    let timerVM: TimerViewModel
    let taskVM: TaskViewModel
    @State private var calendarVM = CalendarViewModel()
    private let settings = UserSettings.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 6) {
                    Text("설정")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider()

                // Timer section
                settingsSectionHeader("타이머")

                settingsRow("포모도로") {
                    Stepper("\(settings.focusDurationMinutes)분",
                            value: Bindable(settings).focusDurationMinutes,
                            in: 1...120)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
                }

                settingsRow("짧은 휴식") {
                    Stepper("\(settings.shortBreakDurationMinutes)분",
                            value: Bindable(settings).shortBreakDurationMinutes,
                            in: 1...60)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
                }

                settingsRow("긴 휴식") {
                    Stepper("\(settings.longBreakDurationMinutes)분",
                            value: Bindable(settings).longBreakDurationMinutes,
                            in: 1...60)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
                }

                settingsRow("자동 시작") {
                    Toggle("", isOn: Bindable(settings).autoStartNextPomodoro)
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                }

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                // Shortcut section
                settingsSectionHeader("단축키")

                HStack {
                    Text("시작/정지")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleTimer)
                        .controlSize(.mini)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                // Calendar section
                settingsSectionHeader("캘린더")

                if calendarVM.isAuthorized {
                    ForEach(calendarVM.calendars) { cal in
                        settingsRow(cal.title) {
                            Toggle("", isOn: Binding(
                                get: { settings.selectedCalendarIds.contains(cal.id) },
                                set: { _ in
                                    calendarVM.toggleCalendar(cal.id)
                                    calendarVM.syncEvents(into: taskVM)
                                }
                            ))
                            .toggleStyle(.switch)
                            .controlSize(.mini)
                        }
                    }

                    Button("일정 새로고침") {
                        calendarVM.syncEvents(into: taskVM)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                } else {
                    Text("macOS 캘린더에 등록된 모든 계정의 일정을 불러옵니다.")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)

                    Button("캘린더 접근 허용") {
                        Task { await calendarVM.requestAccess() }
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.pomodoroFocus)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }

                if let error = calendarVM.errorMessage {
                    Text(error)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)
                }

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                // General section
                settingsSectionHeader("일반")

                settingsRow("로그인 시 자동 시작") {
                    Toggle("", isOn: Binding(
                        get: { settings.launchAtLogin },
                        set: { newValue in
                            settings.launchAtLogin = newValue
                            do {
                                if newValue {
                                    try SMAppService.mainApp.register()
                                } else {
                                    try SMAppService.mainApp.unregister()
                                }
                            } catch {
                                settings.launchAtLogin = !newValue
                            }
                        }
                    ))
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                }

                settingsRow("알림 사운드") {
                    Toggle("", isOn: Bindable(settings).soundEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxHeight: 380)
        .task {
            if calendarVM.isAuthorized {
                calendarVM.loadCalendars()
                calendarVM.syncEvents(into: taskVM)
            }
        }
    }

    // MARK: - Helpers

    private func settingsSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(.quaternary)
            .textCase(.uppercase)
            .tracking(1.5)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private func settingsRow<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.primary)
            Spacer()
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}
