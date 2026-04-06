# Pomodoro

A lightweight macOS menu bar Pomodoro timer built with Swift 6 and SwiftUI.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Menu Bar App** — Lives in your menu bar, always accessible without cluttering your dock
- **Visual Progress** — Circular progress indicator in the menu bar shows time remaining at a glance
- **Task Management** — Create, complete, and track tasks alongside your Pomodoro sessions
- **Calendar Integration** — Import today's calendar events as tasks
- **Keyboard Shortcuts** — Start/pause timer with customizable global shortcuts
- **Customizable Timers** — Adjust focus, short break, and long break durations
- **Auto-start** — Optionally auto-start the next Pomodoro after a short break
- **Notifications** — Get notified when a session ends
- **Launch at Login** — Start automatically when you log in

## Requirements

- macOS 14.0 (Sonoma) or later
- Swift 6.0 / Xcode 16+

## Build & Run

```bash
# Clone the repository
git clone https://github.com/tnlvof/pomodoro.git
cd pomodoro

# Build and run
./run.sh
```

Or build manually:

```bash
swift build -c debug
```

## How It Works

The app follows the [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique):

1. **Focus** (25 min) — Work on a task with full concentration
2. **Short Break** (5 min) — Take a quick break
3. Repeat 4 times, then take a **Long Break** (15 min)

All durations are configurable in settings.

## Project Structure

```
Pomodoro/
├── PomodoroApp.swift          # App entry point, menu bar setup
├── Models/
│   ├── PomodoroState.swift    # Timer state machine
│   ├── PomodoroSession.swift  # Session history
│   ├── UserSettings.swift     # Persisted user preferences
│   └── TaskItem.swift         # Task model
├── ViewModels/
│   ├── TimerViewModel.swift   # Timer logic
│   ├── TaskViewModel.swift    # Task management
│   └── CalendarViewModel.swift # Calendar integration
├── Views/
│   ├── PopoverView.swift      # Main popover container
│   ├── TimerView.swift        # Timer display & controls
│   ├── TaskListView.swift     # Task list
│   ├── TaskRowView.swift      # Individual task row
│   └── InlineSettingsView.swift # Settings panel
└── Services/
    ├── StorageService.swift    # Data persistence
    ├── NotificationService.swift # User notifications
    └── CalendarService.swift   # EventKit integration
```

## License

[MIT](LICENSE)
