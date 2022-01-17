
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
        
        guard #available(macOS 10.15, *) else {
            print("This code only runs on macOS 10.15 and up")
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
            let document = Presenter(q, weekWidth: 5).present()
            print(document.emit())
        }
        catch {
            print("ERROR \(error)")
            throw error
        }
    }
}

termcalendar.main()
