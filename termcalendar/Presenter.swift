import Foundation

// protocol Emitable {
//     func emit() -> String
// }

// @resultBuilder
// struct HTMLBuilder {
//     static func buildBlock(_ components: Emitable...) -> Emitable {
//         return HTML()
//     }
//     static func buildEither(first: Emitable) -> Emitable {
//         return first
//     }
//     static func buildEither(second: Emitable) -> Emitable {
//         return second
//     }
// }

// func emit(@HTMLBuilder content: () -> Emitable) -> Emitable {
//     return content()
// }

// struct HTML: Emitable {
//     var content: String
//     init(_ content: String) { self.content = content }
//     func emit() -> String { return content }
// }

// func makeDocument(for quartermaster: Quartermaster) -> Emitable {
//     let html = draw {
//         HTML
//     }
//     return html
// }

let dayOfWeekName = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

let monthName = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
]


class Presenter {
    let calendarSource: CalendarSource
    var weekCount = 0
    let weekWidth = 7

    init(_ cs: CalendarSource, weekWidth: Int) {
        self.calendarSource = cs
        self.weekWidth = weekWidth
    }

    func present() {
        // let doc = makeDocument(for: quartermaster)
        // print(doc.emit())

        html()
    }

    func html() {
        defer { print("</html>") }
        print("<!DOCTYPE html><html>")
        head()
        body()
    }

    func head() {
        print("""
        <head>
        <style>
        table, th, td {
        border: 1px solid black;
        }
        .noClassDay {
            background-color: lightgrey;
            text-align:center;
            width: 100px;
            height: 60px;
        }
        .classDay {
            background-color: white; 
            text-align:center;
            width: 100px;
            height: 60px;
        }
        .rowHeader {
            background-color: darkgrey;
            text-align:center;
            width: 90px;
            height: 60px;
        }
        </style>
        </head>
        """)
    }

    func body() {
        defer { print("</body>") }
        print("<body>")
        h(1, calendarSource.title)
        table()
        h(3, calendarSource.footnote)
    }

    func h(_ level: Int, _ text: String) {
        print("<h\(level)>\(text)</h\(level)>")
    }

    func table() {
        defer { print("</table>") }
        print("<table>")
        tableHeader()
        
        weekCount = 0
        var week = [Day]()
        var dayOfWeek = 0
        for day in calendarSource.days { // the first is always Monday of the week school starts
            
            if dayOfWeek < weekWidth {
                week.append(day)
            }
            if week.count == weekWidth {
                tableRow(week)
                week = [Day]()
            }
            dayOfWeek += 1
            if dayOfWeek > 6 {
                dayOfWeek = 0
            }
        }
    }

    func tableHeader() {
        print("""
        <tr>
        <td>Week</td>
        """)
        for d in dayOfWeekName[0..<weekWidth] {
            print("<th scope=\"col\">\(d)</th>")
        }
        print("</tr>")
    }

    func tableRow(_ week: [Day]) {
        weekCount += 1
        print("<tr>")
        rowHeaderView(week)

        for day in week {
            dayView(day)
        }
        print("</tr>")
    }

    func rowHeaderView(_ w: [Day]) {
        print("<th scope=\"row\" class=\"rowHeader\">")
        print("\(weekCount)")
    
        print("<br>")
        
        if w.first!.month == w.last!.month {
            print("\(monthName[w.first!.month.rawValue])")
        } else {
            print("\(monthName[w.first!.month.rawValue]) - \(monthName[w.last!.month.rawValue])")
        }
        print("</th>")
    }

    func dayView(_ d: Day) {
        print("""
        <td class="\(d.inSession ? "classDay" : "noClassDay")">
        \(d.dayOfMonth)
        <br>
        \(d.events.first ?? "")
        <br>
        """)

        let iconfn: (Day.Icon?)->(String,String)? = { icon in
            guard let icon = icon else {
                return nil
            }
            switch icon {
                case .Canvas:
                    return ("data:image/png;base64,\(canvasIconBase64)==", "Canvas sesssion")
                case .Zoom:
                    return ("data:image/png;base64,\(zoomIconBase64)==", "Zoom class")
            }
        }
        
        if let (src, alt) = iconfn(d.icon) {
            print("<img src=\"\(src)\" alt=\"\(alt)\" width=\"30\" height=\"30\">")
        }

        print("</td>")
    }
}
