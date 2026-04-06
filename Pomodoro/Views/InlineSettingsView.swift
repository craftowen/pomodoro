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
            VStack(alignment: .leading, spacing: 12) {
                // Timer
                SectionHeader("타이머")

                Stepper("포모도로: \(settings.focusDurationMinutes)분",
                        value: Bindable(settings).focusDurationMinutes,
                        in: 1...120)
                Stepper("짧은 휴식: \(settings.shortBreakDurationMinutes)분",
                        value: Bindable(settings).shortBreakDurationMinutes,
                        in: 1...60)
                Stepper("긴 휴식: \(settings.longBreakDurationMinutes)분",
                        value: Bindable(settings).longBreakDurationMinutes,
                        in: 1...60)
                Toggle("휴식 후 자동 시작", isOn: Bindable(settings).autoStartNextPomodoro)

                Divider()

                // Shortcut
                SectionHeader("단축키")

                HStack {
                    Text("시작/정지:")
                        .font(.system(size: 12))
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleTimer)
                }

                Divider()

                // Calendar
                SectionHeader("캘린더")

                if calendarVM.isAuthorized {
                    ForEach(calendarVM.calendars) { cal in
                        Toggle(cal.title, isOn: Binding(
                            get: { settings.selectedCalendarIds.contains(cal.id) },
                            set: { _ in
                                calendarVM.toggleCalendar(cal.id)
                                calendarVM.syncEvents(into: taskVM)
                            }
                        ))
                        .font(.system(size: 12))
                    }

                    Button("일정 새로고침") {
                        calendarVM.syncEvents(into: taskVM)
                    }
                    .font(.system(size: 12))
                } else {
                    Text("macOS 캘린더에 등록된 모든 계정(Google, iCloud 등)의 일정을 불러옵니다.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    Button("캘린더 접근 허용") {
                        Task { await calendarVM.requestAccess() }
                    }
                    .font(.system(size: 12))
                }

                if let error = calendarVM.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }

                Divider()

                // General
                SectionHeader("일반")

                Toggle("로그인 시 자동 시작", isOn: Binding(
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

                Toggle("알림 사운드", isOn: Bindable(settings).soundEnabled)
            }
            .font(.system(size: 12))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(maxHeight: 380)
        .task {
            if calendarVM.isAuthorized {
                calendarVM.loadCalendars()
                calendarVM.syncEvents(into: taskVM)
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}
