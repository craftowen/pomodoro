import XCTest
@testable import Pomodoro

final class CalendarViewModelTests: XCTestCase {
    func testNextMidnightReturnsStartOfNextDay() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!

        var comps = DateComponents()
        comps.year = 2026
        comps.month = 4
        comps.day = 14
        comps.hour = 15
        comps.minute = 30
        comps.timeZone = cal.timeZone
        let now = cal.date(from: comps)!

        let next = CalendarViewModel.nextMidnight(after: now, calendar: cal)

        let expectedComps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: next)
        XCTAssertEqual(expectedComps.year, 2026)
        XCTAssertEqual(expectedComps.month, 4)
        XCTAssertEqual(expectedComps.day, 15)
        XCTAssertEqual(expectedComps.hour, 0)
        XCTAssertEqual(expectedComps.minute, 0)
        XCTAssertEqual(expectedComps.second, 0)
    }

    func testNextMidnightFromExactMidnightAdvancesOneDay() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!

        var comps = DateComponents()
        comps.year = 2026
        comps.month = 4
        comps.day = 14
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        comps.timeZone = cal.timeZone
        let midnight = cal.date(from: comps)!

        let next = CalendarViewModel.nextMidnight(after: midnight, calendar: cal)

        XCTAssertEqual(next.timeIntervalSince(midnight), 86400, accuracy: 1)
    }

    func testNextMidnightAcrossDSTTransitionProducesPositiveInterval() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Los_Angeles")!

        var comps = DateComponents()
        comps.year = 2026
        comps.month = 3
        comps.day = 7
        comps.hour = 22
        comps.timeZone = cal.timeZone
        let beforeDST = cal.date(from: comps)!

        let next = CalendarViewModel.nextMidnight(after: beforeDST, calendar: cal)
        XCTAssertGreaterThan(next.timeIntervalSince(beforeDST), 0)
        XCTAssertLessThan(next.timeIntervalSince(beforeDST), 2 * 86400)
    }

    // MARK: - Polling interval (±25% jitter)

    func testPollingIntervalAtMidRandomEqualsBase() {
        let interval = CalendarViewModel.pollingInterval(base: 900, jitterFraction: 0.25, random: 0.5)
        XCTAssertEqual(interval, 900, accuracy: 0.0001)
    }

    func testPollingIntervalAtRandomZeroIsBaseMinusJitter() {
        let interval = CalendarViewModel.pollingInterval(base: 900, jitterFraction: 0.25, random: 0)
        XCTAssertEqual(interval, 675, accuracy: 0.0001) // 900 - 25%
    }

    func testPollingIntervalAtRandomOneIsBasePlusJitter() {
        let interval = CalendarViewModel.pollingInterval(base: 900, jitterFraction: 0.25, random: 1)
        XCTAssertEqual(interval, 1125, accuracy: 0.0001) // 900 + 25%
    }

    func testPollingIntervalClampsRandomOutOfRange() {
        let low = CalendarViewModel.pollingInterval(base: 900, jitterFraction: 0.25, random: -5)
        let high = CalendarViewModel.pollingInterval(base: 900, jitterFraction: 0.25, random: 5)
        XCTAssertEqual(low, 675, accuracy: 0.0001)
        XCTAssertEqual(high, 1125, accuracy: 0.0001)
    }

    func testPollingIntervalStaysWithinJitterBounds() {
        for _ in 0..<200 {
            let r = Double.random(in: 0...1)
            let interval = CalendarViewModel.pollingInterval(base: 900, jitterFraction: 0.25, random: r)
            XCTAssertGreaterThanOrEqual(interval, 675)
            XCTAssertLessThanOrEqual(interval, 1125)
        }
    }
}
