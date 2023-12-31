import Foundation
import Metal


struct Day {
    enum Icon: String {
        case Canvas = "Canvas_Blue"
        case Zoom = "ZPLogo"
    }
    
    let dayOfMonth: Int
    let month: CalendarConstants.Month
    var inSession: Bool = true
    var events = [String](repeating: "", count: 2)
    var icon: Icon? = nil
    
    init(month: CalendarConstants.Month, day: Int, inSession: Bool = true, events: [String] = [], icon: Icon? = nil) {
        self.month = month
        self.dayOfMonth = day
        self.inSession = inSession
        self.events = events
        self.icon = icon
    }
}

struct Week {
    let days: [Day]
}

enum CalendarConstants: Int {
    
    case WeekLength = 7
    
    enum DayOfWeek: Int {
        case Monday = 0
        case Tuesday
        case Wednesday
        case Thursday
        case Friday
        case Saturday
        case Sunday
        
        static let weekdays: Set<DayOfWeek> = [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday]
        
        func isWeekend() -> Bool {
            return self == .Sunday || self == .Saturday
        }
    }
    
    enum Month: Int {
        case January
        case February
        case March
        case April
        case May
        case June
        case July
        case August
        case September
        case October
        case November
        case December
    }
    
    static func dateInfo(from date: Date) -> (Self.Month, Int, Self.DayOfWeek) {
        let dateComps = Calendar.current.dateComponents([.month, .day, .weekday], from: date)
        let month = Self.Month(rawValue: dateComps.month! - 1)!
        let rawDayOfWeek = dateComps.weekday! - 2
        let dayOfWeek = rawDayOfWeek < 0
            ? Self.DayOfWeek.Sunday
            : Self.DayOfWeek(rawValue: rawDayOfWeek)!

        return (month, dateComps.day!, dayOfWeek)
    }
}

protocol CalendarSource {
    var title: String { get }
    var footnote: String { get }
    var weeks: [Week] { get }
}
