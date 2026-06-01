# Data Model: macOS Pomodoro Timer App

**Date**: 2026-04-06  
**Feature Branch**: `001-macos-pomodoro-app`

## Entities

### PomodoroSession

포모도로 한 세션(작업 또는 휴식)의 기록.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | 고유 식별자 |
| type | SessionType | `.focus`, `.shortBreak`, `.longBreak` |
| startedAt | Date | 세션 시작 시각 |
| endedAt | Date? | 세션 종료 시각 (nil이면 진행 중 또는 취소됨) |
| duration | TimeInterval | 설정된 세션 길이 (초) |
| taskId | UUID? | 연결된 할 일 항목 ID (없으면 nil) |
| status | SessionStatus | `.completed`, `.cancelled` |

### TaskItem

할 일 항목. 구글 캘린더에서 가져오거나 수동 입력.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | 고유 식별자 |
| title | String | 업무명 (메뉴바 표시용) |
| source | TaskSource | `.manual`, `.googleCalendar` |
| calendarEventId | String? | 구글 캘린더 이벤트 ID (캘린더 출처일 때) |
| scheduledTime | Date? | 예정 시각 (종일 이벤트는 nil) |
| isAllDay | Bool | 종일 이벤트 여부 |
| isCompleted | Bool | 완료 상태 |
| isSelected | Bool | 현재 작업으로 선택되었는지 |
| createdAt | Date | 생성 시각 |

### PomodoroState (런타임 전용, 비저장)

현재 타이머 상태 머신.

| Field | Type | Description |
|-------|------|-------------|
| phase | TimerPhase | `.idle`, `.focus`, `.shortBreak`, `.longBreak` |
| remainingSeconds | Int | 남은 시간 (초) |
| isPaused | Bool | 일시정지 여부 |
| cycleCount | Int | 현재 사이클 내 완료된 포모도로 수 (0~3) |
| currentTaskId | UUID? | 현재 선택된 작업 ID |

### UserSettings

사용자 설정. UserDefaults에 저장.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| focusDuration | Int | 1500 (25분) | 포모도로 시간 (초) |
| shortBreakDuration | Int | 300 (5분) | 짧은 휴식 시간 (초) |
| longBreakDuration | Int | 900 (15분) | 긴 휴식 시간 (초) |
| autoStartNextPomodoro | Bool | false | 휴식 후 자동 시작 |
| globalShortcut | KeyCombo? | nil | 글로벌 단축키 |
| launchAtLogin | Bool | false | 로그인 시 자동 시작 |
| selectedCalendarIds | [String] | [] | 선택된 구글 캘린더 ID 목록 |
| soundEnabled | Bool | true | 알림 사운드 활성화 |

### GoogleAuthToken (Keychain 저장)

| Field | Type | Description |
|-------|------|-------------|
| accessToken | String | API 접근 토큰 |
| refreshToken | String | 토큰 갱신용 |
| expiresAt | Date | 만료 시각 |

## State Transitions

### Timer Phase State Machine

```
[idle] ---(start/shortcut)---> [focus]
[focus] ---(complete)---> [shortBreak] (cycleCount < 3)
[focus] ---(complete)---> [longBreak] (cycleCount == 3)
[focus] ---(reset)---> [idle]
[focus] ---(pause)---> [focus.paused]
[focus.paused] ---(resume)---> [focus]
[shortBreak] ---(complete + autoStart)---> [focus]
[shortBreak] ---(complete + manual)---> [idle]
[shortBreak] ---(skip)---> [idle]
[longBreak] ---(complete)---> [idle] (cycleCount 리셋)
[longBreak] ---(skip)---> [idle] (cycleCount 리셋)
```

## Relationships

- PomodoroSession → TaskItem: 다대일 (하나의 작업에 여러 포모도로 가능)
- PomodoroState → TaskItem: 일대일 (현재 선택된 작업)
- TaskItem의 source가 `.googleCalendar`이면 calendarEventId가 필수
