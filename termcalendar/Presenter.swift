import Foundation

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

protocol Emitable {
    func emit() -> String
}

protocol Element: Emitable {
}

struct EmptyElement: Element {
    func emit() -> String {
        ""
    }
}


extension String: Element {
    func emit() -> String {
        return self
    }
}

@resultBuilder
struct StylesBuilder {
    typealias Component = [Style]
    typealias Expression = String
    
    // Combines an array of partial results into a single partial result. A result builder must implement this method.
    static func buildBlock(_ components: Component...) -> Component {
        return components.flatMap { $0 }
    }
    static func buildBlock(_ components: Expression...) -> Component {
        return components.map {
            Style($0)
        }
    }
}

@resultBuilder
struct TableHeaderBuilder {
    typealias Expression = ColumnHeader
    typealias Component = [ColumnHeader]
    static func buildEither(first component: Component) -> Component {
        return component
    }
    static func buildEither(second component: Component) -> Component {
        return component
    }
    
    static func buildArray(_ components: [Component]) -> Component {
        return Array(components.joined())
    }
    static func buildBlock(_ components: Component...) -> Component {
        return Array(components.joined())
    }
    
    // Builds a partial result from an expression. You can implement this method to perform preprocessing—for example, converting expressions to an internal type—or to provide additional information for type inference at use sites.
    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }
}

@resultBuilder
struct TableRowBuilder {
    typealias Component = [TableCell]
    typealias Expression = TableCell
    
    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }
    
    static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return [TableCell]() }
        return component
    }
    static func buildEither(first component: Component) -> Component {
        return component
    }
    static func buildEither(second component: Component) -> Component {
        return component
    }
    static func buildArray(_ components: [Component]) -> Component {
        return Array(components.joined())
    }
    static func buildBlock(_ components: Component...) -> Component {
        return Array(components.joined())
    }
}


@resultBuilder
struct BodyBuilder {
    typealias Expression = Element
    typealias Component = [Element]
    
    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }
    
    static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return Component() }
        return component
    }
    static func buildEither(first component: Component) -> Component {
        return component
    }
    static func buildEither(second component: Component) -> Component {
        return component
    }
    static func buildArray(_ components: [Component]) -> Component {
        return  components.flatMap { $0 }
    }
    static func buildBlock(_ components: Component...) -> Component {
        return  components.flatMap { $0 }
    }
}


@resultBuilder
struct RowsBuilder {
    typealias Component = [TableRow]
    typealias Expression = TableRow
    
    static func buildExpression(_ element: Expression) -> Component {
        return [element]
    }
    static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return [TableRow]() }
        return component
    }
    static func buildEither(first component: Component) -> Component {
        return component
    }
    static func buildEither(second component: Component) -> Component {
        return component
    }
    static func buildArray(_ components: [Component]) -> Component {
        return Array(components.joined())
    }
    static func buildBlock(_ components: Component...) -> Component {
        return Array(components.joined())
    }
}

struct HTMLDocument: Emitable {
    let docType: String
    let head: Head
    let body: Body
    let footer: Footer
    
    func emit() -> String {
        return "<!DOCTYPE \(docType)><html>"
        + head.emit()
        + body.emit()
        + footer.emit()
        + "</html>"
    }
}

struct Style: Emitable {
    let directive: String
    
    init(_ d: String) {
        directive = d
    }
    
    func emit() -> String {
        return directive
    }
}

struct Head: Emitable {
    let styles: [Style]
    
    init(@StylesBuilder content: () -> [Style]) {
        styles = content()
    }
    
    func emit() -> String {
        return "<head>\n"
        + "<style>\n"
        + styles.map { style in
            style.emit()
        }
        .joined(separator: "\n")
        + "\n</style>"
        + "\n</head>"
    }
}

struct Footer: Emitable {
    func emit() -> String {
        ""
    }
}

struct Body: Emitable {
    let contents: [Element]
    
    init(@BodyBuilder content: () -> [Element]) {
        contents = content()
    }
    
    func emit() -> String {
        "<BODY>"
        + contents.map {
            $0.emit()
        }
        .joined(separator: "\n")
        + "\n</BODY>"
    }
}


struct H: Element {
    let level: Int
    let text: String
    
    func emit() -> String {
        return "<h\(level)>\(text)</h\(level)>"
    }
}

struct BR: Element {
    func emit() -> String { "<br/>\n" }
}

struct P: Element {
    let text: String?
    
    init(_ t: String? = nil ) {
        text = t
    }
    
    func emit() -> String {
        if let text = text {
            return "<P>\(text)</P>"
        } else {
            return "<P>\n"
        }
    }
}


struct Table: Element {
    let header: TableHeader
    let rows: [TableRow]
    
    init(header: TableHeader, @RowsBuilder rows: () -> [TableRow]) {
        self.header = header
        self.rows = rows()
    }
    
    func emit() -> String {
        "<table>\n"
        + header.emit()
        + "\n"
        + rows.map {
            $0.emit()
        }
        .joined(separator: "\n")
        + "\n</table>"
    }
}


struct RowHeader: Element {
    let klass: String?
    let contents: [Element]
    
    init(klass: String? = nil, @BodyBuilder content: () -> [Element]) {
        self.klass = klass
        contents = content()
    }
    
    func emit() -> String {
        
        let klassStr: String
        if klass == nil {
            klassStr = ""
        }
        else {
            klassStr = " class=\"\(klass!)\""
        }
        
        return "<th scope=\"row\"\(klassStr)>"
        + contents.map {
            $0.emit()
        }.joined(separator: "\n")
        + "</th>"
    }
}

struct ColumnHeader: Element {
    let text: String
    init(_ t: String, klass: String? = nil) {
        text = t
    }
    func emit() -> String {
        "<th scope=\"col\">\(text)</th>"
    }
}

struct TableHeader: Emitable {
    var columnHeaders: [ColumnHeader]
    
    init(@TableHeaderBuilder columnHeaders: () -> [ColumnHeader]) {
        self.columnHeaders = columnHeaders()
    }
    
    func emit() -> String {
        return "<TR>"
        + columnHeaders.map {
            $0.emit()
        }
        .joined(separator: "")
        + "</TR>"
    }
}

struct TableCell: Element {
    let klass: String?
    let contents: [Element]
    
    init(klass: String, @BodyBuilder contents: () -> [Element]) {
        self.klass = klass
        self.contents = contents()
    }
    
    func emit() -> String {
        return (klass == nil ? "<TD>" : "<TD class=\"\(klass!)\">")
        + contents.map {
            $0.emit()
        }
        .joined(separator: "")
        + "</TD>"
    }
}

struct TableRow: Emitable {
    let header: RowHeader
    var row: [TableCell]
    
    init(header: RowHeader, @TableRowBuilder tableCells: () -> [TableCell]) {
        self.header = header
        self.row = tableCells()
    }
    
    func emit() -> String {
        return "<TR>"
        + header.emit()
        + row.map {
            $0.emit()
        }
        .joined(separator: "")
        + "</TR>"
    }
}

struct Img: Element {
    let src: String
    let alt: String
    let width: Int
    let height: Int
    
    func emit() -> String {
        return "<img src=\"\(src)\" alt=\"\(alt)\" width=\"\(width)\" height=\"\(height)\" />"
    }
}

class Presenter {
    let calendarSource: CalendarSource
    let weekWidth: Int
    
    init(_ cs: CalendarSource, weekWidth: Int) {
        self.calendarSource = cs
        self.weekWidth = weekWidth
    }
    
    func present() -> HTMLDocument {
        
        return HTMLDocument(docType: "html",
                            head: Head {
                                        """
                                        table, th, td {
                                            border: 1px solid black;
                                        }
                                        """
                                        """
                                        .noClassDay {
                                            background-color: lightgrey;
                                            text-align:center;
                                            width: 100px;
                                            height: 60px;
                                        }
                                        """
                                        """
                                        .classDay {
                                            background-color: white;
                                            text-align:center;
                                            width: 100px;
                                            height: 60px;
                                        }
                                        """
                                        """
                                        .rowHeader {
                                            background-color: darkgrey;
                                            text-align:center;
                                            width: 90px;
                                            height: 60px;
                                        }
                                        """
        },
                            body: Body {
            
            H(level: 1, text: calendarSource.title)
            
            Table(
                header: TableHeader {
                    ColumnHeader("Week")
                    
                    for name in dayOfWeekName[0..<weekWidth] {
                        ColumnHeader("\(name)")
                    }
                },
                rows: {
                    
                    for (weekIndex, week) in calendarSource.weeks.enumerated() {
                        
                        let firstDay = week.days.first!
                        let lastDay = week.days.last!
                        let headerText = firstDay.month == lastDay.month
                        ? "\(monthName[firstDay.month.rawValue])"
                        : "\(monthName[firstDay.month.rawValue]) - \(monthName[lastDay.month.rawValue])"
                        
                        TableRow(header: RowHeader(klass: "rowHeader", content: {
                            "\(weekIndex+1)"
                            BR()
                            headerText
                        })) {
                            
                            for day in week.days[0..<weekWidth] {
                                
                                TableCell(klass: day.inSession ? "classDay" : "noClassDay") {
                                    
                                    "\(day.dayOfMonth)"
                                    
                                    BR()
                                    
                                    "\(day.events.first ?? "")"
                                    
                                    BR()
                                    
                                    let tuple = icon(for: day.icon)
                                    if tuple != nil {
                                        Img(src: tuple!.0, alt: tuple!.1, width: 30, height: 30)
                                    }
                                }
                            }
                        }
                    }
                })
            
            H(level: 3, text: calendarSource.footnote)
        },
                            
                            footer: Footer())
    }
}

func icon(for icon: Day.Icon?) -> (String,String)? {
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

