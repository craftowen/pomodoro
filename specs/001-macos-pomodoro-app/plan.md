# Implementation Plan: macOS Pomodoro Timer App

**Branch**: `001-macos-pomodoro-app` | **Date**: 2026-04-06 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-macos-pomodoro-app/spec.md`

## Summary

macOS 상단 메뉴바에 상주하는 최소 기능 포모도로 타이머 앱. 글로벌 단축키로 즉시 시작/정지, 팝오버에서 할 일 목록 관리, 구글 캘린더 연동으로 오늘 일정 자동 가져오기. 모든 데이터 로컬 저장. SwiftUI MenuBarExtra 기반 네이티브 앱.

## Technical Context

**Language/Version**: Swift 6 / Xcode 16+  
**Primary Dependencies**: SwiftUI (MenuBarExtra), KeyboardShortcuts, ServiceManagement, UserNotifications, AuthenticationServices  
**Storage**: UserDefaults (설정) + JSON 파일 (할 일, 세션 기록) + Keychain (OAuth 토큰)  
**Testing**: XCTest  
**Target Platform**: macOS 13 (Ventura)+  
**Project Type**: desktop-app (menu bar)  
**Performance Goals**: 메모리 50MB 미만, 타이머 1초 정확도  
**Constraints**: 로컬 전용, 외부 의존성 최소 (KeyboardShortcuts 1개), Dock에 표시하지 않음 (LSUIElement)  
**Scale/Scope**: 단일 사용자, 일일 할 일 수십 건 이하

## Constitution Check

*GATE: Constitution이 미설정 상태 (빈 템플릿) — 위반 사항 없음. 통과.*

## Project Structure

### Documentation (this feature)

```text
specs/001-macos-pomodoro-app/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0: Technology research
├── data-model.md        # Phase 1: Data model
├── quickstart.md        # Phase 1: Setup guide
├── contracts/
│   └── ui-contract.md   # Phase 1: UI contract
└── checklists/
    └── requirements.md  # Spec quality checklist
```

### Source Code (repository root)

```text
Pomodoro/
├── PomodoroApp.swift              # @main, MenuBarExtra 정의
├── Models/
│   ├── PomodoroState.swift        # 타이머 상태 머신 (idle/focus/break)
│   ├── PomodoroSession.swift      # 세션 기록 엔티티
│   ├── TaskItem.swift             # 할 일 항목 엔티티
│   └── UserSettings.swift         # 설정 (Codable + UserDefaults)
├── ViewModels/
│   ├── TimerViewModel.swift       # 타이머 로직, 상태 전환, 알림
│   ├── TaskViewModel.swift        # 할 일 CRUD, 선택/완료
│   └── CalendarViewModel.swift    # 구글 캘린더 OAuth + 이벤트 조회
├── Views/
│   ├── PopoverView.swift          # 메인 팝오버 (타이머 + 목록)
│   ├── TimerView.swift            # 타이머 표시 + 컨트롤 버튼
│   ├── TaskListView.swift         # 할 일 목록 UI
│   ├── TaskRowView.swift          # 개별 할 일 행
│   └── SettingsView.swift         # 설정 윈도우
├── Services/
│   ├── GoogleCalendarService.swift # OAuth2 + Calendar API REST
│   ├── KeychainService.swift      # Security framework 래퍼
│   ├── NotificationService.swift  # UNUserNotificationCenter 래퍼
│   └── StorageService.swift       # JSON 파일 읽기/쓰기
└── Resources/
    └── Assets.xcassets            # 앱 아이콘

PomodoroTests/
├── TimerViewModelTests.swift      # 타이머 상태 전환 테스트
├── TaskViewModelTests.swift       # 할 일 CRUD 테스트
├── PomodoroStateTests.swift       # 상태 머신 단위 테스트
└── StorageServiceTests.swift      # 저장/로드 테스트
```

**Structure Decision**: 단일 Xcode 프로젝트. MVVM 패턴. 모델은 Codable 구조체, 뷰모델은 @Observable 클래스. 서비스 레이어로 외부 시스템(Keychain, 파일, 구글 API) 추상화.

## Complexity Tracking

> Constitution 미설정 — 위반 사항 없음.
