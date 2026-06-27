import XCTest
@testable import Pomodoro

final class TaskViewModelTests: XCTestCase {
    // MARK: - Calendar merge preserves local state

    func testMergePreservesCompletionForSameCalendarEvent() {
        var existingDone = TaskItem(title: "회의", source: .systemCalendar, calendarEventId: "E1")
        existingDone.isCompleted = true

        // 동기화 시 캘린더에서 다시 만들어진 fresh 이벤트(미완료)
        let incoming = TaskItem(title: "회의", source: .systemCalendar, calendarEventId: "E1")

        let merged = TaskViewModel.mergedCalendarTasks(existing: [existingDone], events: [incoming])

        XCTAssertEqual(merged.count, 1)
        XCTAssertTrue(merged[0].isCompleted, "동기화 후에도 완료 상태가 유지돼야 한다")
        XCTAssertEqual(merged[0].id, existingDone.id, "동일 이벤트는 같은 id를 유지해야 한다")
    }

    func testMergePreservesSelectionForSameCalendarEvent() {
        var existingSelected = TaskItem(title: "집중", source: .systemCalendar, calendarEventId: "E2")
        existingSelected.isSelected = true

        let incoming = TaskItem(title: "집중", source: .systemCalendar, calendarEventId: "E2")

        let merged = TaskViewModel.mergedCalendarTasks(existing: [existingSelected], events: [incoming])

        XCTAssertEqual(merged.count, 1)
        XCTAssertTrue(merged[0].isSelected, "동기화 후에도 선택 상태가 유지돼야 한다")
    }

    func testMergeUpdatesCalendarMetadataButKeepsCompletion() {
        var existingDone = TaskItem(
            title: "옛 제목",
            source: .systemCalendar,
            calendarEventId: "E3",
            scheduledTime: Date(timeIntervalSince1970: 1_000),
            isAllDay: false
        )
        existingDone.isCompleted = true

        let newTime = Date(timeIntervalSince1970: 2_000)
        let incoming = TaskItem(
            title: "새 제목",
            source: .systemCalendar,
            calendarEventId: "E3",
            scheduledTime: newTime,
            isAllDay: false
        )

        let merged = TaskViewModel.mergedCalendarTasks(existing: [existingDone], events: [incoming])

        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].title, "새 제목", "캘린더 메타데이터(제목)는 최신으로 갱신돼야 한다")
        XCTAssertEqual(merged[0].scheduledTime, newTime, "예정 시각도 최신으로 갱신돼야 한다")
        XCTAssertTrue(merged[0].isCompleted, "메타데이터가 바뀌어도 완료 상태는 유지돼야 한다")
    }

    func testMergeKeepsManualTasksUntouched() {
        var manualDone = TaskItem(title: "수동 할 일", source: .manual)
        manualDone.isCompleted = true

        let incoming = TaskItem(title: "캘린더 할 일", source: .systemCalendar, calendarEventId: "E4")

        let merged = TaskViewModel.mergedCalendarTasks(existing: [manualDone], events: [incoming])

        XCTAssertEqual(merged.count, 2)
        let manual = merged.first { $0.source == .manual }
        XCTAssertNotNil(manual)
        XCTAssertTrue(manual!.isCompleted, "수동 항목은 그대로 보존돼야 한다")
        XCTAssertEqual(manual!.id, manualDone.id)
    }

    func testMergeDropsCalendarEventNoLongerPresent() {
        var stale = TaskItem(title: "삭제된 이벤트", source: .systemCalendar, calendarEventId: "GONE")
        stale.isCompleted = true

        // 캘린더에서 더는 조회되지 않음
        let merged = TaskViewModel.mergedCalendarTasks(existing: [stale], events: [])

        XCTAssertTrue(merged.isEmpty, "캘린더에서 사라진 이벤트는 제거돼야 한다")
    }

    func testMergeAddsBrandNewCalendarEvent() {
        let incoming = TaskItem(title: "새 이벤트", source: .systemCalendar, calendarEventId: "NEW")

        let merged = TaskViewModel.mergedCalendarTasks(existing: [], events: [incoming])

        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].calendarEventId, "NEW")
        XCTAssertFalse(merged[0].isCompleted)
    }
}
