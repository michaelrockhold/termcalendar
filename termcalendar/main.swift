
import Foundation
import ArgumentParser

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

            let q = try Quartermaster(calendarname: self.calendar,
                                      firstDay: b,
                                      lastDay: e,
                                      title: title,
                                      footnote: footnote)
            Presenter(q).present()
        }
        catch {
            print("ERROR \(error)")
            throw error
        }
    }
}

termcalendar.main()
