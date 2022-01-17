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

struct ElementGroup: Element {
    let contents: [Element]
    func emit() -> String {
        return contents.map {
            $0.emit()
        }
        .joined(separator: "\n")
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
        return Array(components.joined())
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
//    typealias FinalResult = [ColumnHeader]
        
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
    typealias Component = Element
    typealias FinalResult = ElementGroup
//    typealias Expression = Element

    static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return EmptyElement() }
        return component
    }
    static func buildEither(first component: Component) -> Component {
        return component
    }
    static func buildEither(second component: Component) -> Component {
        return component
    }
    static func buildArray(_ components: [Component]) -> Component {
        return ElementGroup(contents: components)
    }
    static func buildBlock(_ components: Component...) -> Component {
        return ElementGroup(contents: components)
    }
    
    static func buildFinalResult(_ component: Component) -> FinalResult {
        return ElementGroup(contents: [component])
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
    @StylesBuilder let styles: [Style]
    
    func emit() -> String {
        return "<head>"
        + "<style>"
        + styles.map { style in
            style.emit()
        }
        .joined(separator: "\n")
        + "</style>"
        + "</head>"
    }
}

struct Footer: Emitable {
    func emit() -> String {
        ""
    }
}

struct Body: Emitable {
    @BodyBuilder let contents: ElementGroup
    
    func emit() -> String {
        "<BODY>"
        + contents.emit()
        + "</BODY>"
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
    func emit() -> String { "<br/>" }
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
            return "<P>"
        }
    }
}


struct Table: Element {
    let header: TableHeader
    @RowsBuilder let rows: [TableRow]
    
    func emit() -> String {
        "<table></table>"
    }
}


struct RowHeader: Element {
    let text: String
    init(_ t: String, klass: String? = nil) {
        text = t
    }
    
    func emit() -> String {
        "<th scope=\"row\">\(text)</th>"
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
    @TableHeaderBuilder var columnHeaders: [ColumnHeader]
    
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
    @BodyBuilder let contents: ElementGroup
    
    func emit() -> String {
        return (klass == nil ? "<TD>" : "<TD class=\"\(klass!)\">")
        + contents.emit()
        + "</TD>"
    }
}

struct TableRow: Emitable {
    let header: RowHeader
    
    @TableRowBuilder var row: [TableCell]
    
    func emit() -> String {
        return "<TR>"
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
    var weekCount = 0
    
    init(_ cs: CalendarSource, weekWidth: Int) {
        self.calendarSource = cs
        self.weekWidth = weekWidth
    }
    
    func present() -> HTMLDocument {
        
        return HTMLDocument(docType: "html",
                            head: Head(styles: {
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
                                }),
                            body: Body {
            
            H(level: 1, text: calendarSource.title)
            
            Table(
                header: TableHeader {
                    ColumnHeader("Week")
                    
                    for (name, i) in dayOfWeekName[0..<weekWidth].enumerated() {
                        ColumnHeader("\(name)")
                    }
                },
                rows: {
                    
                    for (i, week) in calendarSource.weeks.enumerated() {
                        
                        let firstDay = week.days.first!
                        let lastDay = week.days.last!
                        let headerText = firstDay.month == lastDay.month
                        ? "\(monthName[firstDay.month.rawValue])"
                        : "\(monthName[firstDay.month.rawValue]) - \(monthName[lastDay.month.rawValue])"
                        
                        TableRow(header: RowHeader("\(weekCount)\n\(headerText)", klass: "rowHeader")) {
                            
                            for (j, day) in week.days.enumerated() {
                                
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

