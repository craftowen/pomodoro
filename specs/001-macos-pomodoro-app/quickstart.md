# Quickstart: macOS Pomodoro Timer App

**Date**: 2026-04-06  
**Feature Branch**: `001-macos-pomodoro-app`

## Prerequisites

- macOS 13 (Ventura) 이상
- Xcode 16+
- Swift 6
- Google Cloud Console 프로젝트 (캘린더 연동 시)

## Project Setup

```bash
# 1. Xcode 프로젝트 생성 (App, SwiftUI, macOS)
# Xcode > File > New > Project > macOS > App
# Product Name: Pomodoro
# Interface: SwiftUI
# Language: Swift

# 2. Swift Package Manager 의존성 추가
# Package.swift 또는 Xcode > File > Add Package Dependencies
# - https://github.com/sindresorhus/KeyboardShortcuts
```

## Project Configuration

### Info.plist

```xml
<!-- 커스텀 URL 스킴 (OAuth 리다이렉트) -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>pomodoro</string>
        </array>
    </dict>
</array>

<!-- LSUIElement: 메뉴바 전용 앱 (Dock에 표시하지 않음) -->
<key>LSUIElement</key>
<true/>
```

### Google OAuth Setup

1. Google Cloud Console에서 OAuth 2.0 클라이언트 ID 생성 (Desktop App 유형)
2. Calendar API 활성화
3. Client ID와 Client Secret를 앱에 번들 (또는 별도 설정 파일)
4. Redirect URI: `pomodoro://oauth`

## Architecture Overview

```
Pomodoro/
├── PomodoroApp.swift          # @main, MenuBarExtra 정의
├── Models/
│   ├── PomodoroState.swift    # 타이머 상태 머신
│   ├── TaskItem.swift         # 할 일 항목
│   └── UserSettings.swift     # 설정 (Codable)
├── ViewModels/
│   ├── TimerViewModel.swift   # 타이머 로직 + 알림
│   ├── TaskViewModel.swift    # 할 일 목록 관리
│   └── CalendarViewModel.swift # 구글 캘린더 연동
├── Views/
│   ├── PopoverView.swift      # 메인 팝오버
│   ├── TimerView.swift        # 타이머 표시 + 컨트롤
│   ├── TaskListView.swift     # 할 일 목록
│   └── SettingsView.swift     # 설정 윈도우
├── Services/
│   ├── GoogleCalendarService.swift  # OAuth + Calendar API
│   ├── KeychainService.swift        # 토큰 저장
│   ├── NotificationService.swift    # UNUserNotificationCenter
│   └── StorageService.swift         # JSON 파일 읽기/쓰기
└── Resources/
    └── Assets.xcassets        # 앱 아이콘, 사운드
```

## Build & Run

```bash
# Xcode에서 빌드
xcodebuild -scheme Pomodoro -configuration Debug build

# 또는 Xcode에서 Cmd+R로 실행
```

## Key Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| KeyboardShortcuts | 글로벌 단축키 등록/녹화 | latest |

외부 의존성은 KeyboardShortcuts 하나만 사용. 나머지는 모두 Apple 기본 프레임워크:
- SwiftUI, AppKit (MenuBarExtra)
- ServiceManagement (SMAppService)
- UserNotifications (UNUserNotificationCenter)
- AuthenticationServices (ASWebAuthenticationSession)
- Security (Keychain)
