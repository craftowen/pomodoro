# Tasks: macOS Pomodoro Timer App

**Input**: Design documents from `/specs/001-macos-pomodoro-app/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/ui-contract.md, quickstart.md

**Tests**: 테스트 태스크는 spec에서 별도 요청되지 않았으므로 포함하지 않음.

**Organization**: User Story 단위로 구성. 각 Story는 독립적으로 구현/테스트 가능.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 병렬 실행 가능 (다른 파일, 의존성 없음)
- **[Story]**: 해당 User Story 라벨 (US1, US2, US3)
- 모든 경로는 Pomodoro/ 프로젝트 루트 기준

---

## Phase 1: Setup (프로젝트 초기화)

**Purpose**: Xcode 프로젝트 생성 및 기본 구조 설정

- [x] T001 Xcode macOS App 프로젝트 생성 (Product Name: Pomodoro, SwiftUI, Swift 6) in Pomodoro/
- [x] T002 KeyboardShortcuts SPM 의존성 추가 (https://github.com/sindresorhus/KeyboardShortcuts) in Pomodoro/Package.swift
- [x] T003 [P] Info.plist 설정: LSUIElement=true (Dock 숨김), CFBundleURLSchemes=pomodoro (OAuth 리다이렉트) in Pomodoro/Info.plist
- [x] T004 [P] 디렉토리 구조 생성: Models/, ViewModels/, Views/, Services/, Resources/ in Pomodoro/

---

## Phase 2: Foundational (공통 기반)

**Purpose**: 모든 User Story가 의존하는 핵심 모델과 서비스

**CRITICAL**: 이 단계 완료 전까지 User Story 작업 불가

- [x] T005 [P] UserSettings 모델 구현 (Codable, UserDefaults 연동, 기본값 포함) in Pomodoro/Models/UserSettings.swift
- [x] T006 [P] PomodoroState 모델 구현 (TimerPhase enum, 상태 머신 전환 로직) in Pomodoro/Models/PomodoroState.swift
- [x] T007 [P] PomodoroSession 모델 구현 (세션 기록 엔티티, Codable) in Pomodoro/Models/PomodoroSession.swift
- [x] T008 [P] TaskItem 모델 구현 (할 일 항목, TaskSource enum, Codable) in Pomodoro/Models/TaskItem.swift
- [x] T009 [P] StorageService 구현 (JSON 파일 읽기/쓰기, Application Support 디렉토리) in Pomodoro/Services/StorageService.swift
- [x] T010 [P] NotificationService 구현 (UNUserNotificationCenter 래퍼, 권한 요청, 알림 스케줄) in Pomodoro/Services/NotificationService.swift
- [x] T011 PomodoroApp 엔트리포인트 구현 (MenuBarExtra with .window style, 기본 팝오버) in Pomodoro/PomodoroApp.swift

**Checkpoint**: 기반 모델과 서비스 준비 완료. User Story 구현 시작 가능.

---

## Phase 3: User Story 1 - 단축키로 포모도로 즉시 시작/정지 (Priority: P1) MVP

**Goal**: 글로벌 단축키로 포모도로 시작/일시정지. 메뉴바에 남은 시간 실시간 표시. 25분→5분→반복, 4회 후 15분 긴 휴식. 리셋/스킵 지원.

**Independent Test**: 앱 실행 후 단축키로 타이머 시작 → 메뉴바에 카운트다운 표시 → 완료 시 알림 → 휴식 전환 확인

### Implementation for User Story 1

- [x] T012 [US1] TimerViewModel 구현: Timer 기반 1초 카운트다운, 상태 전환 (focus→break→focus), 사이클 카운트, 일시정지/재개/리셋/스킵 로직, 세션 완료/취소 시 PomodoroSession 생성 후 StorageService로 저장 in Pomodoro/ViewModels/TimerViewModel.swift
- [x] T013 [US1] TimerViewModel에 알림 연동: 포모도로/휴식 종료 시 NotificationService 호출, 사운드 설정 반영 in Pomodoro/ViewModels/TimerViewModel.swift
- [x] T014 [US1] TimerViewModel에 글로벌 단축키 연동: KeyboardShortcuts.onKeyUp으로 시작/일시정지 토글 in Pomodoro/ViewModels/TimerViewModel.swift
- [x] T015 [US1] TimerViewModel에 자동 시작/수동 시작 설정 반영: UserSettings.autoStartNextPomodoro 체크 후 휴식 종료 동작 분기 in Pomodoro/ViewModels/TimerViewModel.swift
- [x] T016 [US1] TimerViewModel에 커스텀 시간 설정 반영: UserSettings의 focusDuration/shortBreakDuration/longBreakDuration 사용 in Pomodoro/ViewModels/TimerViewModel.swift
- [x] T017 [US1] TimerView 구현: 타이머 표시 (MM:SS), 사이클 인디케이터 (포모도로 N/4), 일시정지/리셋/스킵 버튼 (UI Contract 참조) in Pomodoro/Views/TimerView.swift
- [x] T018 [US1] 메뉴바 타이틀 동적 업데이트: PomodoroApp에서 TimerViewModel 상태에 따라 메뉴바 텍스트 변경 (아이콘 + 남은시간) in Pomodoro/PomodoroApp.swift
- [x] T019 [US1] PopoverView 기본 구현: TimerView 배치 + 하단 설정/종료 버튼 in Pomodoro/Views/PopoverView.swift
- [x] T020 [US1] SettingsView 타이머 설정 섹션: 포모도로/짧은 휴식/긴 휴식 시간 입력, 자동 시작 토글, 단축키 녹화 (KeyboardShortcuts.Recorder) in Pomodoro/Views/SettingsView.swift
- [x] T021 [US1] 잠자기 모드 복귀 처리: NSWorkspace.willSleepNotification/didWakeNotification 구독, 경과 시간 보정 in Pomodoro/ViewModels/TimerViewModel.swift

**Checkpoint**: 포모도로 타이머 핵심 기능 완성. 단축키 시작 → 메뉴바 카운트다운 → 알림 → 휴식 전환 → 사이클 반복 동작 확인.

---

## Phase 4: User Story 2 - 메뉴바에서 오늘의 할 일 확인 및 선택 (Priority: P2)

**Goal**: 팝오버에서 할 일 목록 표시. 항목 선택 시 메뉴바에 업무명 표시. 수동 추가/삭제/완료.

**Independent Test**: 할 일 수동 추가 → 항목 선택 → 메뉴바에 업무명 표시 → 포모도로 시작 시 "업무명 MM:SS" 표시

### Implementation for User Story 2

- [x] T022 [US2] TaskViewModel 구현: 할 일 CRUD (추가/삭제/완료 토글), 선택/해제 로직, StorageService로 JSON 저장/로드, 날짜별 필터링 in Pomodoro/ViewModels/TaskViewModel.swift
- [x] T023 [US2] TaskRowView 구현: 개별 할 일 행 (선택 상태 ●/○, 시간 표시, 완료 시 취소선, 출처 라벨) in Pomodoro/Views/TaskRowView.swift
- [x] T024 [US2] TaskListView 구현: 할 일 목록 (종일→시간순 정렬, 빈 상태 메시지, 하단 추가 버튼 + 인라인 텍스트 필드) in Pomodoro/Views/TaskListView.swift
- [x] T025 [US2] PopoverView에 TaskListView 통합: TimerView 아래에 할 일 목록 배치 in Pomodoro/Views/PopoverView.swift
- [x] T026 [US2] 메뉴바 타이틀에 업무명 반영: 선택된 TaskItem.title을 메뉴바에 표시 (15자 말줄임), 타이머 진행 중이면 "업무명 MM:SS" in Pomodoro/PomodoroApp.swift
- [x] T027 [US2] TimerViewModel과 TaskViewModel 연동: 포모도로 시작 시 currentTaskId 설정, 세션 기록에 taskId 포함 in Pomodoro/ViewModels/TimerViewModel.swift

**Checkpoint**: 할 일 수동 관리 + 포모도로 연결 완성. 업무 선택 → 포모도로 시작 → 메뉴바에 업무명+타이머 표시.

---

## Phase 5: User Story 3 - 구글 캘린더 연동으로 할 일 자동 불러오기 (Priority: P3)

**Goal**: 구글 캘린더 OAuth 연동. 오늘 이벤트를 할 일 목록에 자동 추가. 캘린더 선택 기능.

**Independent Test**: 구글 계정 연동 → 캘린더 선택 → 오늘 이벤트가 할 일 목록에 표시 → 오프라인 시 캐시 데이터 표시

### Implementation for User Story 3

- [x] T028 [P] [US3] KeychainService 구현: GoogleAuthToken 구조체 정의 (accessToken/refreshToken/expiresAt), Security framework 래퍼 (토큰 저장/로드/삭제) in Pomodoro/Services/KeychainService.swift
- [x] T029 [US3] GoogleCalendarService OAuth 구현: ASWebAuthenticationSession으로 인증, 토큰 교환, 토큰 갱신, KeychainService로 저장 in Pomodoro/Services/GoogleCalendarService.swift
- [x] T030 [US3] GoogleCalendarService 캘린더 목록 조회: Calendar List API 호출, 사용 가능한 캘린더 목록 반환 in Pomodoro/Services/GoogleCalendarService.swift
- [x] T031 [US3] GoogleCalendarService 이벤트 조회: Events.list API 호출 (오늘 날짜, 선택된 캘린더), TaskItem으로 변환 in Pomodoro/Services/GoogleCalendarService.swift
- [x] T032 [US3] CalendarViewModel 구현: 연동 상태 관리, 캘린더 선택, 이벤트 동기화, 오프라인 캐시 처리, 자동 갱신 (앱 시작/날짜 변경) in Pomodoro/ViewModels/CalendarViewModel.swift
- [x] T033 [US3] TaskViewModel에 캘린더 이벤트 통합: CalendarViewModel에서 가져온 이벤트를 수동 할 일과 병합, 종일→시간순 정렬 in Pomodoro/ViewModels/TaskViewModel.swift
- [x] T034 [US3] SettingsView 구글 캘린더 섹션: 연동/해제 버튼, 캘린더 체크리스트 (복수 선택) in Pomodoro/Views/SettingsView.swift
- [x] T035 [US3] 오프라인/에러 처리: 네트워크 실패 시 캐시 사용, 권한 취소 감지, 재연동 안내 in Pomodoro/Services/GoogleCalendarService.swift

**Checkpoint**: 구글 캘린더 연동 완성. OAuth 인증 → 캘린더 선택 → 오늘 이벤트 자동 표시 → 오프라인 폴백.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 전체 품질 향상 및 마무리

- [x] T036 [P] SettingsView 일반 섹션: 로그인 시 자동 시작 (SMAppService), 알림 사운드 토글 in Pomodoro/Views/SettingsView.swift
- [x] T037 [P] 앱 아이콘 및 에셋 추가 (토마토 아이콘) in Pomodoro/Resources/Assets.xcassets
- [x] T038 앱 종료 기능: PopoverView 하단 종료 버튼 → NSApplication.shared.terminate in Pomodoro/Views/PopoverView.swift
- [x] T039 메모리/성능 검증: 50MB 미만 확인, Timer 누수 없는지 확인
- [x] T040 quickstart.md 기반 전체 플로우 검증: 빌드 → 실행 → 단축키 → 할 일 → 캘린더 연동

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: 의존성 없음 — 즉시 시작
- **Phase 2 (Foundational)**: Phase 1 완료 필요 — 모든 User Story 차단
- **Phase 3 (US1)**: Phase 2 완료 후 시작 가능
- **Phase 4 (US2)**: Phase 2 완료 후 시작 가능 (US1과 병렬 가능하나, 메뉴바 타이틀 공유로 US1 이후 권장)
- **Phase 5 (US3)**: Phase 4 완료 후 시작 권장 (TaskViewModel 통합 필요)
- **Phase 6 (Polish)**: 모든 User Story 완료 후

### User Story Dependencies

- **US1 (P1)**: Phase 2 이후 독립 실행 가능. 다른 Story에 의존하지 않음.
- **US2 (P2)**: Phase 2 이후 실행 가능. US1의 메뉴바 타이틀 로직과 통합 필요 (T026).
- **US3 (P3)**: US2의 TaskViewModel 필요 (T033). US2 완료 후 진행.

### Within Each User Story

- Models → ViewModels → Views → Integration 순서
- ViewModel 내부 태스크는 순차 (같은 파일)
- 다른 파일 태스크는 [P] 가능

### Parallel Opportunities

- Phase 2: T005~T010 모두 병렬 (서로 다른 파일)
- Phase 3 (US1): T017 (View)은 T012~T016 (ViewModel) 이후
- Phase 5 (US3): T028 (Keychain)은 Phase 시작 시 즉시 실행 가능. T029~T031은 T028 완료 후 순차 진행

---

## Parallel Example: User Story 1

```bash
# Phase 2 병렬 실행 (모든 모델 + 서비스):
Task: "T005 UserSettings 모델" in Pomodoro/Models/UserSettings.swift
Task: "T006 PomodoroState 모델" in Pomodoro/Models/PomodoroState.swift
Task: "T007 PomodoroSession 모델" in Pomodoro/Models/PomodoroSession.swift
Task: "T008 TaskItem 모델" in Pomodoro/Models/TaskItem.swift
Task: "T009 StorageService" in Pomodoro/Services/StorageService.swift
Task: "T010 NotificationService" in Pomodoro/Services/NotificationService.swift

# US1 ViewModel 순차 (같은 파일):
Task: "T012 TimerViewModel 기본" → T013 → T014 → T015 → T016 순차

# US1 View 병렬 (ViewModel 완료 후):
Task: "T017 TimerView" in Pomodoro/Views/TimerView.swift
Task: "T019 PopoverView" in Pomodoro/Views/PopoverView.swift
Task: "T020 SettingsView" in Pomodoro/Views/SettingsView.swift
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup → Xcode 프로젝트 생성
2. Phase 2: Foundational → 모델 + 서비스
3. Phase 3: US1 → 포모도로 타이머 + 단축키 + 메뉴바
4. **STOP and VALIDATE**: 단축키로 타이머 시작/정지, 메뉴바 카운트다운 확인
5. MVP 완성 — 이것만으로도 사용 가능한 포모도로 앱

### Incremental Delivery

1. Setup + Foundational → 기반 준비
2. + US1 → 포모도로 타이머 (MVP)
3. + US2 → 할 일 관리 + 업무 연결
4. + US3 → 구글 캘린더 연동
5. + Polish → 자동 시작, 아이콘, 최종 검증

---

## Notes

- [P] = 다른 파일, 의존성 없이 병렬 가능
- [USn] = 해당 User Story 소속
- 모든 ViewModel은 @Observable 클래스 (Swift Observation)
- 모든 Model은 Codable struct
- 커밋: 각 태스크 또는 논리적 그룹 단위
- 각 Checkpoint에서 독립 검증 후 다음 Phase 진행
