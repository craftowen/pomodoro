<!--
  Sync Impact Report
  - Version change: 0.0.0 (template) → 1.0.0
  - Added principles:
    - I. Minimal Viable Scope
    - II. Platform-Native First
    - III. Offline-First Storage
    - IV. Ship Fast, Iterate Later
  - Removed sections:
    - [PRINCIPLE_5_NAME] (template had 5 slots; project uses 4)
    - [SECTION_2_NAME] (not needed)
    - [SECTION_3_NAME] (not needed)
  - Templates requiring updates:
    - ✅ .specify/templates/plan-template.md — Constitution Check section
        references generic gates; no update needed (gates filled at plan time)
    - ✅ .specify/templates/spec-template.md — no constitution-specific sections
    - ✅ .specify/templates/tasks-template.md — no constitution-specific sections
  - Follow-up TODOs: none
-->

# Pomodoro Constitution

## Core Principles

### I. Minimal Viable Scope

spec에 명시된 Functional Requirements만 구현한다. 추측성 기능을 금지한다.

- 구현 대상은 spec.md의 FR 목록에 한정한다. FR에 없는 기능 MUST NOT 구현
- 추상화는 동일 패턴이 3회 이상 반복될 때만 도입한다
- 서드파티 의존성은 KeyboardShortcuts 1개로 제한한다. 나머지는 플랫폼 네이티브 API를 사용한다
- 새로운 의존성 추가 시 plan.md Complexity Tracking에 근거를 기록해야 한다

### II. Platform-Native First

Apple 플랫폼 네이티브 API를 우선 사용한다.

- SwiftUI MenuBarExtra, UserNotifications, ServiceManagement, AuthenticationServices 등 시스템 프레임워크를 MUST 사용
- 래퍼 라이브러리, 크로스플랫폼 추상화 레이어 MUST NOT 도입
- UIKit/AppKit 브릿지는 SwiftUI로 불가능한 경우에만 허용하며, 사유를 plan.md에 기록한다

### III. Offline-First Storage

로컬 저장소만으로 앱이 완전히 동작해야 한다.

- 설정: UserDefaults
- 세션/태스크 데이터: JSON 파일 (Application Support 디렉토리)
- OAuth 토큰: Keychain
- 외부 DB, 서버, 클라우드 스토리지 MUST NOT 의존
- Google Calendar 연동은 선택적 부가 기능이며, 연결 실패 시에도 타이머 핵심 기능은 정상 동작해야 한다

### IV. Ship Fast, Iterate Later

핵심 기능의 동작을 최우선으로 한다.

- 구현 순서: 타이머 상태 머신 → 메뉴바 UI → 알림 → 태스크 관리 → 캘린더 연동
- 에러 핸들링은 크래시 방지 수준까지만 구현. 정교한 복구 로직은 후순위
- UI 폴리싱(애니메이션, 마이크로 인터랙션)은 핵심 기능 검증 후 진행
- 첫 릴리스에서 모든 FR을 완벽히 커버하지 않아도 된다. P1 User Story 완성이 최소 출시 기준

## Governance

- 이 Constitution은 모든 spec, plan, tasks 문서보다 상위 규범이다
- 원칙 위반이 필요한 경우 plan.md Complexity Tracking 테이블에 위반 사유와 거부된 대안을 기록해야 한다
- 개정 시 버전을 올리고, 변경 사유를 Sync Impact Report에 기록한다
- 버전 규칙: MAJOR(원칙 삭제/재정의), MINOR(원칙 추가/확장), PATCH(문구 수정)

**Version**: 1.0.0 | **Ratified**: 2026-04-06 | **Last Amended**: 2026-04-06
