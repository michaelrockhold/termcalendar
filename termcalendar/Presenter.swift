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
struct StylesBuilder<G: Generator> {
    typealias Component = [G.Style]
    typealias Expression = String
    
    // Combines an array of partial results into a single partial result. A result builder must implement this method.
    static func buildBlock(_ components: Component...) -> Component {
        return components.flatMap { $0 }
    }
    static func buildBlock(_ components: Expression...) -> Component {
        return components.map {
            G.Style($0)
        }
    }
}

@resultBuilder
struct TableHeaderBuilder<G: Generator> {
    typealias Expression = G.ColumnHeader
    typealias Component = [G.ColumnHeader]
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
struct TableRowBuilder<G: Generator> {
    typealias Component = [G.TableCell]
    typealias Expression = G.TableCell
    
    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }
    
    static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return [G.TableCell]() }
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
struct RowsBuilder<G: Generator> {
    typealias Component = [G.TableRow]
    typealias Expression = G.TableRow
    
    static func buildExpression(_ element: Expression) -> Component {
        return [element]
    }
    static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return [G.TableRow]() }
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

protocol Document_: Emitable { }
protocol Head_: Emitable { }
protocol Body_: Emitable { }
protocol Footer_: Emitable { }
protocol Style_: Emitable {
    init(_ s: String)
}
protocol H_: Element { }
protocol BR_: Element { }
protocol P_: Element { }
protocol Table_: Element { }
protocol RowHeader_: Element { }
protocol ColumnHeader_: Element { }
protocol TableHeader_: Emitable { }
protocol TableCell_: Element { }
protocol TableRow_: Emitable { }
protocol Img_: Element { }

protocol Generator {
    associatedtype Style: Style_
    associatedtype Document: Document_
    associatedtype Head: Head_
    associatedtype Body: Body_
    associatedtype Footer: Footer_
    associatedtype H: H_
    associatedtype BR: BR_
    associatedtype P: P_
    associatedtype Table: Table_
    associatedtype TableHeader: TableHeader_
    associatedtype TableCell: TableCell_
    associatedtype ColumnHeader: ColumnHeader_
    associatedtype TableRow: TableRow_
    associatedtype RowHeader: RowHeader_
    associatedtype Img: Img_
    
    
    func document(head: Head, body: Body, footer: Footer) -> Document
    func head() -> Head
    func body(@BodyBuilder content: () -> [Element]) -> Body
    func footer() -> Footer
    
    func h(level: Int, text: String) -> H
    func br() -> BR
    func p() -> P
    func img(_ icon: Day.Icon, width: Int, height: Int) -> Img
    
    func table(header: TableHeader, @RowsBuilder<Self> rows: () -> [TableRow]) -> Table
    func tableHeader(@TableHeaderBuilder<Self> columnHeaders: () -> [ColumnHeader]) -> TableHeader
    func columnHeader(_ text: String) -> ColumnHeader
    func rowHeader(klass: String?, @BodyBuilder content: () -> [Element]) -> RowHeader
    func tableRow(header: RowHeader, @TableRowBuilder<Self> tableCells: () -> [TableCell]) -> TableRow
    func tableCell(klass: String, @BodyBuilder contents: () -> [Element]) -> TableCell
}

class Presenter<G: Generator> {
    let calendarSource: CalendarSource
    let g: G
    let weekWidth: Int
    
    init(_ cs: CalendarSource, generator: G, weekWidth: Int) where G: Generator {
        self.calendarSource = cs
        self.g = generator
        self.weekWidth = weekWidth
    }
    
    func present() -> G.Document {
        
        return g.document(head: g.head(),
                          body: g.body {
            
            g.h(level: 1, text: calendarSource.title)
            
            g.table(
                header: g.tableHeader {
                    g.columnHeader("Week")
                    
                    for name in dayOfWeekName[0..<weekWidth] {
                        g.columnHeader("\(name)")
                    }
                },
                rows: {
                    
                    for (weekIndex, week) in calendarSource.weeks.enumerated() {
                        
                        let firstDay = week.days.first!
                        let lastDay = week.days.last!
                        let headerText = firstDay.month == lastDay.month
                        ? "\(monthName[firstDay.month.rawValue])"
                        : "\(monthName[firstDay.month.rawValue]) - \(monthName[lastDay.month.rawValue])"
                        
                        g.tableRow(header: g.rowHeader(klass: "rowHeader", content: {
                            "\(weekIndex+1)"
                            g.br()
                            headerText
                        })) {
                            
                            for day in week.days[0..<weekWidth] {
                                
                                g.tableCell(klass: day.inSession ? "classDay" : "noClassDay") {
                                    
                                    "\(day.dayOfMonth)"
                                    
                                    g.br()
                                    
                                    "\(day.events.first ?? "")"
                                    
                                    g.br()
                                    
                                    if day.icon != nil {
                                        g.img(day.icon!, width: 30, height: 30)
                                    }
                                }
                            }
                        }
                    }
                })
            
            g.h(level: 3, text: calendarSource.footnote)
        },
                          footer: g.footer())
    }
}
