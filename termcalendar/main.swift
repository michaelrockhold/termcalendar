
import Foundation
import ArgumentParser
import EventKit


struct termcalendar: ParsableCommand {
    
    @Argument(help: "The calendar to query.")
    var calendar: String
    
    @Argument(help: "Date of the first day of the quarter")
    var firstDayOfTheQuarter: String
    
    @Argument(help: "Date of the last day of the quarter")
    var lastDayOfTheQuarter: String
    
    @Argument(help: "The title to display at the top.")
    var title: String
    
    @Argument(help: "The footnote to display at the bottom.")
    var footnote: String
    
    mutating func run() throws {
        
        let dateFormatter = DateFormatter()
        dateFormatter.monthSymbols
        var dayOfWeekName = dateFormatter.weekdaySymbols!
        let sunday = dayOfWeekName.removeFirst()
        dayOfWeekName.append(sunday)

        guard #available(macOS 10.15, *) else {
            debugPrint("ERROR: This code only runs on macOS 10.15 and up")
            return
        }
        
        do {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            let b = formatter.date(from: "\(firstDayOfTheQuarter)T00:00:01-08:00")!
            let e = formatter.date(from: "\(lastDayOfTheQuarter)T00:00:01-08:00")!
            
            let store = EKEventStore.getStore()
            guard let eventCalendar = store.calendar(where: { c in c.title == calendar }) else {
                throw Quartermaster.QuartermasterError.NoMatchingCalendar
            }
            let events = store.events(matching: store.predicateForEvents(withStart: b,
                                                                         end: e,
                                                                         calendars: [eventCalendar]))
            
            let q = try Quartermaster(events: events,
                                      firstDay: b,
                                      lastDay: e,
                                      title: title,
                                      footnote: footnote)
            let weekWidth = 5
            
            let document = Document(font: "times") {
                Table(
                    title: q.title,
                    caption: q.footnote,
                    header: TableHeader {
                            
                            ColumnHeader("Week")
                            
                            for name in dayOfWeekName[0..<weekWidth] {
                                ColumnHeader("\(name)")
                            }
                        }) {
                            for (weekIndex, week) in q.weeks.enumerated() {
                                
                                let firstDay = week.days.first!
                                let lastDay = week.days.last!
                                let headerText = firstDay.month == lastDay.month
                                ? "\(dateFormatter.monthSymbols[firstDay.month.rawValue])"
                                : "\(dateFormatter.monthSymbols[firstDay.month.rawValue]) - \(dateFormatter.monthSymbols[lastDay.month.rawValue])"
                                
                                Row(header: RowHeader(weekNumber: weekIndex+1, text: headerText)) {
                                    for day in week.days[0..<weekWidth] {
                                        DayCell(day: day)
                                    }
                                }
                            }
                        }
                }
            print(document.emit())
        }
        catch {
            debugPrint("ERROR \(error)")
            throw error
        }
    }
}

termcalendar.main()
