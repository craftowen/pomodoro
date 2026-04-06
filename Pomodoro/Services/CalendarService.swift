import EventKit

@MainActor
final class CalendarService {
    static let shared = CalendarService()

    nonisolated(unsafe) private var store = EKEventStore()

    var isAuthorized: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToEvents()
            if granted {
                refreshStore()
            }
            return granted
        } catch {
            return false
        }
    }

    func refreshStore() {
        store.reset()
        store = EKEventStore()
    }

    func availableCalendars() -> [EKCalendar] {
        store.calendars(for: .event)
    }

    func fetchTodayEvents(calendarIds: [String]) -> [TaskItem] {
        let calendars = store.calendars(for: .event).filter { calendarIds.contains($0.calendarIdentifier) }
        guard !calendars.isEmpty else { return [] }

        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: Date())
        let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: calendars)
        let events = store.events(matching: predicate)

        return events.map { event in
            TaskItem(
                title: event.title ?? "(제목 없음)",
                source: .systemCalendar,
                calendarEventId: event.eventIdentifier,
                scheduledTime: event.isAllDay ? nil : event.startDate,
                isAllDay: event.isAllDay
            )
        }
    }
}
