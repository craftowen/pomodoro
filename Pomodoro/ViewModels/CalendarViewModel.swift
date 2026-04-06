import Foundation
import EventKit

struct CalendarInfo: Identifiable {
    let id: String
    let title: String
    let color: CGColor?
}

@MainActor
@Observable
final class CalendarViewModel {
    var isAuthorized: Bool = false
    var calendars: [CalendarInfo] = []
    var errorMessage: String?

    private let service = CalendarService.shared
    private let settings = UserSettings.shared

    init() {
        isAuthorized = service.isAuthorized
    }

    func requestAccess() async {
        isAuthorized = await service.requestAccess()
        if isAuthorized {
            loadCalendars()
        } else {
            errorMessage = "캘린더 접근이 거부되었습니다. 시스템 설정 > 개인정보 보호에서 허용해주세요."
        }
    }

    func loadCalendars() {
        calendars = service.availableCalendars().map {
            CalendarInfo(id: $0.calendarIdentifier, title: $0.title, color: $0.cgColor)
        }
    }

    func syncEvents(into taskVM: TaskViewModel) {
        let selectedIds = settings.selectedCalendarIds
        guard !selectedIds.isEmpty else { return }

        let events = service.fetchTodayEvents(calendarIds: selectedIds)
        taskVM.mergeCalendarEvents(events)
    }

    func toggleCalendar(_ calendarId: String) {
        if settings.selectedCalendarIds.contains(calendarId) {
            settings.selectedCalendarIds.removeAll { $0 == calendarId }
        } else {
            settings.selectedCalendarIds.append(calendarId)
        }
    }
}
