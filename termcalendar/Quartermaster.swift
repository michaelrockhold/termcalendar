//
//  Quartermaster.swift
//  Quartermaster
//
//  Created by Michael Rockhold on 12/28/21.
//

import Foundation
import EventKit

extension Date: Strideable {
    static let SECONDS_PER_DAY: TimeInterval = 60*60*24
    
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }
    
    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
    
    public func advanced(byDays days: Int) -> Date {
        return self.advanced(by: Date.SECONDS_PER_DAY * Double(days))
    }
    
    fileprivate func dateInfo() -> (CalendarConstants.Month, Int, CalendarConstants.DayOfWeek) {
        CalendarConstants.dateInfo(from: self)
    }
}

extension Day {
    struct ShortDate: Hashable {
        let month: CalendarConstants.Month
        let day: Int
    }
    
    init(_ date: Date, inSession: Bool = true) {
        let (month, dayOfMonth, dayOfWeek) = date.dateInfo()
        self.init(month: month,
                     day: dayOfMonth,
                     inSession: !dayOfWeek.isWeekend() && inSession)
    }
    
    var shortDate: ShortDate {
        return ShortDate(month: month, day: dayOfMonth)
    }
}

typealias EventMap = [Day.ShortDate:Day]

extension EventMap {
    mutating func addEvent(_ date: Date, _ event: String) {

        let defaultDay = Day(date)
        var day = self[defaultDay.shortDate, default: defaultDay]
        if event.first != "[" {
            day.events.append(event)
        } else {
            if day.inSession {
                day.inSession = event != "[NO CLASS]"
            }
            if event == "[CANVAS]" {
                day.icon = .Canvas
            } else if event == "[ZOOM]" {
                day.icon = .Zoom
            }
        }
        self[day.shortDate] = day
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class Quartermaster: CalendarSource {
    
    enum QuartermasterError: Error {
        case OK
        case NoMatchingCalendar
    }
    
    let title: String
    let footnote: String
    let weeks: [Week]
    
    init(events: [EKEvent],
         firstDay b: Date,
         lastDay e: Date,
         title: String,
         footnote: String) throws {
        
        self.title = title
        self.footnote = footnote
        let session = DateInterval(start: b, end: e)
                
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Find the full range of days to display (from Monday of first week to Sunday
        // of last week, a superset of the quarter proper
                
        let rawFirstDay = Calendar.current.dateComponents([.weekday], from: b).weekday! - 2
        let firstCalendarDay = b.advanced(byDays: rawFirstDay * -1)
        let lastDay = Calendar.current.dateComponents([.weekday], from: e).weekday! - 2
        let firstDayOfNextCalendar = e.advanced(byDays: CalendarConstants.WeekLength.rawValue - lastDay)
        
        var eventMap = EventMap()
        
        eventMap.addEvent(b, "The First Day of the Quarter")
        eventMap.addEvent(e, "The Last Day of the Quarter")
        
        events
            .forEach { event in
                eventMap.addEvent(event.startDate, event.title)
            }
        
        var days: [Day] = stride(from: firstCalendarDay,
                            to: firstDayOfNextCalendar,
                            by: Date.SECONDS_PER_DAY)
            .map { date in
                let defaultDay = Day(date, inSession: session.contains(date))
                return eventMap[defaultDay.shortDate, default: defaultDay]
            }
        
        self.weeks = {
            var _weeks = [Week]()
            while !days.isEmpty {
                let week = Week(days: [Day](days.prefix(7)))
                _weeks.append(week)
                days.removeFirst(min(days.count, 7))
            }
            return _weeks
        }()
    }
}
