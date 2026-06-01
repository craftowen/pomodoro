# Research: macOS Pomodoro Timer App

**Date**: 2026-04-06  
**Feature Branch**: `001-macos-pomodoro-app`

## 1. Menu Bar App Framework

**Decision**: SwiftUI `MenuBarExtra` (pure SwiftUI)  
**Rationale**: macOS 13+ 타겟이므로 `MenuBarExtra` API가 안정적으로 사용 가능. `.menuBarExtraStyle(.window)`로 팝오버 스타일 지원. AppKit 의존 없이 SwiftUI만으로 구현 가능.  
**Alternatives considered**:
- NSStatusItem + NSPopover: macOS 12 지원 필요 시에만. 불필요한 AppKit 의존성 추가.

## 2. Global Hotkey

**Decision**: `KeyboardShortcuts` 라이브러리 (sindresorhus/KeyboardShortcuts)  
**Rationale**: 모던 Swift, 활발히 유지보수됨. 단축키 녹화 UI와 UserDefaults 저장 기능 내장. 간결한 API.  
**Alternatives considered**:
- Carbon API: deprecated
- CGEvent tap: 접근성 권한 필요, 구현 복잡
- MASShortcut: Objective-C 기반, 유지보수 감소

## 3. Local Storage

**Decision**: `UserDefaults` (설정) + JSON 파일 (할 일 목록, 포모도로 기록)  
**Rationale**: 최소 기능 원칙에 부합. Codable 프로토콜로 타입 안전한 직렬화. 별도 의존성 없음.  
**Alternatives considered**:
- SwiftData/CoreData: 단순 데이터 구조에 과도한 복잡성
- SQLite: 직접 쿼리 불필요, 관계형 데이터 아님

## 4. Google Calendar OAuth2

**Decision**: `ASWebAuthenticationSession` + 수동 OAuth2 토큰 교환  
**Rationale**: 경량. 커스텀 URI 스킴(예: `pomodoro://oauth`)으로 리다이렉트. URLSession으로 토큰 교환. Keychain에 토큰 저장.  
**Alternatives considered**:
- GoogleSignIn SDK: iOS 중심, 무거움
- AppAuth: 단순 플로우에 불필요한 추가 의존성

## 5. Notifications

**Decision**: `UNUserNotificationCenter`  
**Rationale**: macOS 표준 알림 API. alert + sound 옵션. 메뉴바 앱에서 정상 동작.  
**Alternatives considered**: NSUserNotification (deprecated)

## 6. Login Items

**Decision**: `SMAppService.mainApp` (ServiceManagement framework)  
**Rationale**: macOS 13+ 표준 API. 한 줄로 등록/해제 가능.  
**Alternatives considered**:
- SMLoginItemSetEnabled: deprecated
- LaunchAgents plist: 헬퍼 앱 패턴 필요, 과도한 복잡성

## 7. Language & Target

**Decision**: Swift 6 / macOS 13+ / Xcode 16+  
**Rationale**: 최신 안정 Swift. Strict Concurrency 지원으로 타이머 코드 안전성 확보.

## Summary

| Component | Choice |
|-----------|--------|
| Language | Swift 6 |
| UI Framework | SwiftUI (MenuBarExtra) |
| Global Hotkey | KeyboardShortcuts |
| Storage | UserDefaults + JSON files |
| OAuth | ASWebAuthenticationSession |
| Notifications | UNUserNotificationCenter |
| Login Items | SMAppService |
| Min OS | macOS 13 (Ventura) |
