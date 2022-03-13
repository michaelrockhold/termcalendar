//
//  DocumentStructure.swift
//  termcalendar
//
//  Created by Michael Rockhold on 1/26/22.
//

import Foundation
import Metal
import SwiftUI

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
    typealias Component = [DayCell]
    typealias Expression = DayCell
    
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
        return Array(components.joined())
    }
    static func buildBlock(_ components: Component...) -> Component {
        return Array(components.joined())
    }
}

@resultBuilder
struct DocumentBuilder {
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
    typealias Component = [Row]
    typealias Expression = Row
    
    static func buildExpression(_ element: Expression) -> Component {
        return [element]
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
        return Array(components.joined())
    }
    static func buildBlock(_ components: Component...) -> Component {
        return Array(components.joined())
    }
}

struct Document {
    let contents: [Element]

    init(@DocumentBuilder _ contentsFn: () -> [Element]) {
        self.contents = contentsFn()
    }
    
    func emit() -> String {

        return contents.map {
                    $0.emit()
                }
                .joined(separator: "\n")
    }
}

struct Table: Element {
    let title: String
    let header: TableHeader
    let rows: [Row]
    
    init(title: String, header: TableHeader, @RowsBuilder rowsFn: () -> [Row]) {
        self.title = title
        self.header = header
        self.rows = rowsFn()
    }
    
    func emit() -> String {

        return ""
        + header.emit()
        + "\n"
        + rows.map {
            $0.emit()
        }
        .joined(separator: "\n")
    }
}

struct RowHeader {
    let weekNumber: Int
    let text: String

    func emit() -> String { """
        \"\(weekNumber)
        
        \(text)\"
        """ }
}

struct ColumnHeader {
    let text: String
    
    init(_ t: String) {
        text = t
    }
    
    func emit() -> String { text }
}

struct TableHeader {
    let columnHeaders: [ColumnHeader]
    
    init(@TableHeaderBuilder _ columnHeadersFn: () -> [ColumnHeader]) {
        columnHeaders = columnHeadersFn()
    }

    func emit() -> String {
        return
            columnHeaders.map {
                $0.emit()
            }
            .joined(separator: "\t")
    }
}

struct DayCell {

    let day: Day
    
    init(day: Day) {
        self.day = day
    }

    func emit() -> String {
        //self.dayth = Formatter.ordinal(day.dayOfMonth)
        
        let styles = day.attributes.joined()
                
        let info = day.events.map { event in
                    """
                    \(event)
                    
                    """
        }.joined(separator: "")

        
        return """
            \"\(day.dayOfMonth) \(styles)
            
            \(info)\"
            """
    }
}

struct Row {
    let header: RowHeader
    var cells: [DayCell]
    
    init(header: RowHeader, @TableRowBuilder dayCells: () -> [DayCell]) {
        self.header = header
        self.cells = dayCells()
    }

    func emit() -> String {
        return header.emit()
        + "\t"
        + cells.map {
            $0.emit()
        }
        .joined(separator: "\t")
    }
}

struct Formatter {
    
    static let ordinalFormatter = NumberFormatter()
    
    static func ordinal(_ i: Int) -> String {
        ordinalFormatter.numberStyle = .ordinal
        return ordinalFormatter.string(from: NSNumber(integerLiteral: i))!
    }
}
