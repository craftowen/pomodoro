import SwiftUI
import AppKit
import KeyboardShortcuts
import ServiceManagement

struct InlineSettingsView: View {
    let timerVM: TimerViewModel
    let taskVM: TaskViewModel
    let updaterService: UpdaterService
    @State private var calendarVM = CalendarViewModel()
    private let settings = UserSettings.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Timer section
                settingsSectionHeader(String(localized: "settings.timer"))

                settingsRow(String(localized: "settings.pomodoro")) {
                    durationStepper(
                        value: Bindable(settings).focusDurationMinutes,
                        range: 1...120
                    )
                }

                settingsRow(String(localized: "settings.shortBreak")) {
                    durationStepper(
                        value: Bindable(settings).shortBreakDurationMinutes,
                        range: 1...60
                    )
                }

                settingsRow(String(localized: "settings.longBreak")) {
                    durationStepper(
                        value: Bindable(settings).longBreakDurationMinutes,
                        range: 1...60
                    )
                }

                settingsRow(String(localized: "settings.autoStart")) {
                    Toggle("", isOn: Bindable(settings).autoStartNextPomodoro)
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                }

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                // Shortcut section
                settingsSectionHeader(String(localized: "settings.shortcuts"))

                HStack {
                    Text(String(localized: "settings.startStop"))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleTimer)
                        .controlSize(.mini)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                // Calendar section
                settingsSectionHeader(String(localized: "settings.calendar"))

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

                    Button(String(localized: "settings.refreshEvents")) {
                        calendarVM.syncEvents(into: taskVM)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                } else {
                    Text(String(localized: "settings.calendarDescription"))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)

                    Button {
                        Task { await calendarVM.requestAccess() }
                    } label: {
                        Text(String(localized: "settings.allowCalendar"))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.pomodoroFocus)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }

                if let error = calendarVM.errorMessage {
                    Text(error)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)
                }

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                // General section
                settingsSectionHeader(String(localized: "settings.general"))

                settingsRow(String(localized: "settings.launchAtLogin")) {
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

                settingsRow(String(localized: "settings.sound")) {
                    Toggle("", isOn: Bindable(settings).soundEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                }

                settingsRow(checkForUpdatesLabel) {
                    Button {
                        updaterService.checkForUpdates()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!updaterService.canCheckForUpdates)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxHeight: 380)
        .task {
            refreshCalendarConnection()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshCalendarConnection()
        }
    }

    // MARK: - Helpers

    private func settingsSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(1.5)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private func durationStepper(value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack(spacing: 4) {
            Button {
                if value.wrappedValue > range.lowerBound {
                    value.wrappedValue -= 1
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .semibold))
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Text(String(format: String(localized: "settings.duration"), value.wrappedValue))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.primary)
                .frame(minWidth: 44)

            Button {
                if value.wrappedValue < range.upperBound {
                    value.wrappedValue += 1
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .semibold))
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
    }

    private func settingsRow<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
            Spacer()
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var checkForUpdatesLabel: String {
        let currentKey = "settings.checkForUpdates"
        let currentValue = String(localized: "settings.checkForUpdates", defaultValue: "settings.checkForUpdates")
        if currentValue != currentKey {
            return currentValue
        }

        let legacyKey = "settings.checkForUpdate"
        let legacyValue = String(localized: "settings.checkForUpdate", defaultValue: "settings.checkForUpdate")
        if legacyValue != legacyKey {
            return legacyValue
        }

        return "Check for Updates"
    }

    private func refreshCalendarConnection() {
        calendarVM.refreshAuthStatus()
        if calendarVM.isAuthorized {
            calendarVM.syncEvents(into: taskVM)
        } else {
            taskVM.mergeCalendarEvents([])
        }
    }
}
