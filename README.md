<p align="center">
  <h1 align="center">Pomodoro</h1>
  <p align="center">
    A lightweight macOS menu bar Pomodoro timer built with Swift 6 and SwiftUI.
    <br />
    <a href="https://github.com/craftowen/pomodoro/releases/latest"><strong>Download Latest Release</strong></a>
    &nbsp;&middot;&nbsp;
    <a href="https://github.com/craftowen/pomodoro/issues">Report Bug</a>
    &nbsp;&middot;&nbsp;
    <a href="https://github.com/craftowen/pomodoro/issues">Request Feature</a>
  </p>
</p>

<p align="center">
  <a href="https://github.com/craftowen/pomodoro/releases/latest">
    <img src="https://img.shields.io/github/v/release/craftowen/pomodoro?label=version&style=flat-square" alt="Latest Release" />
  </a>
  <img src="https://img.shields.io/badge/macOS-14.0%2B-blue?style=flat-square" alt="macOS 14.0+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 6.0" />
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/craftowen/pomodoro?style=flat-square" alt="License" />
  </a>
</p>

<!-- TODO: Add screenshot or GIF of the app in action
<p align="center">
  <img src="assets/screenshot.png" width="320" alt="Pomodoro Screenshot" />
</p>
-->

## Features

- **Menu Bar App** — Lives in your menu bar, always accessible without cluttering your dock
- **Visual Progress** — Circular progress indicator shows time remaining at a glance
- **Task Management** — Create, complete, and track tasks alongside your Pomodoro sessions
- **Calendar Integration** — Import today's calendar events as tasks via EventKit
- **Keyboard Shortcuts** — Start/pause timer with customizable global shortcuts
- **Customizable Timers** — Adjust focus, short break, and long break durations
- **Auto-start** — Optionally auto-start the next Pomodoro after a break
- **Notifications** — Get notified when a session ends
- **Launch at Login** — Start automatically when you log in
- **i18n** — English, Korean, and Simplified Chinese

## Installation

### Homebrew (recommended)

```bash
brew tap craftowen/pomodoro https://github.com/craftowen/pomodoro
brew install --cask pomodoro
```

> **Note:** If the app doesn't start due to macOS quarantine:
> ```bash
> brew install --cask --no-quarantine pomodoro
> ```

### Download

Download the latest `.app` from the [Releases](https://github.com/craftowen/pomodoro/releases/latest) page.

### Build from Source

```bash
git clone https://github.com/craftowen/pomodoro.git
cd pomodoro
./run.sh
```

## How It Works

The app follows the [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique):

| Phase | Default Duration | Description |
|-------|-----------------|-------------|
| Focus | 25 min | Work on a task with full concentration |
| Short Break | 5 min | Take a quick break |
| Long Break | 15 min | Rest after 4 focus sessions |

All durations are configurable in settings.

## Requirements

- macOS 14.0 (Sonoma) or later
- Swift 6.0 / Xcode 16+ (build from source only)

<details>
<summary><strong>Project Structure</strong></summary>

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
│   ├── InlineSettingsView.swift # Settings panel
│   └── DesignTokens.swift     # Color & style tokens
└── Services/
    ├── StorageService.swift    # Data persistence
    ├── NotificationService.swift # User notifications
    └── CalendarService.swift   # EventKit integration
```

</details>

## Contributing

Contributions are welcome! Feel free to open an [issue](https://github.com/craftowen/pomodoro/issues) or submit a pull request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgments

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.
