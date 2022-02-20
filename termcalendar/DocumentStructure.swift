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
    let font: String

    init(font: String, @DocumentBuilder _ contentsFn: () -> [Element]) {
        self.font = font
        self.contents = contentsFn()
    }
    
    func emit() -> String {
        return """
                \\documentclass{article}
                \\usepackage{\(font)}
                \\usepackage{graphicx}
                \\usepackage[export]{adjustbox}
                \\usepackage{color}
                \\usepackage{blindtext}
                \\usepackage{geometry}
                \\geometry{
                 letterpaper,
                 total={170mm,257mm},
                 left=16mm,
                 top=4mm,
                 }
                \\graphicspath{ {./images/} }
                \\begin{document}
                \\thispagestyle{empty} %suppress page number
                
                """
                + contents.map {
                    $0.emit()
                }
                .joined(separator: "\n")
               + """
                \\end{document}
                """
    }
}

struct Table: Element {
    let title: String
    let caption: String
    let header: TableHeader
    let rows: [Row]
    
    init(title: String, caption: String, header: TableHeader, @RowsBuilder rowsFn: () -> [Row]) {
        self.title = title
        self.caption = caption
        self.header = header
        self.rows = rowsFn()
    }
    
    func emit() -> String {

        return """
        \\begin{table}
            \\centering\\small
            {\\large {\(title)}}\\\\
            \\vspace{0.6 em}
        """
        + header.emit()
        + "\n"
        + rows.map {
            $0.emit()
        }
        .joined(separator: "\n")
        + """
            \\end{tabular}\\\\
            \\vspace{1.0 em}
            \(caption)
            \\end{table}
            """
    }
}

struct RowHeader {
    let weekNumber: Int
    let text: String
    let height = "1.9cm"
    let width = "2cm"

    func emit() -> String {
        return "{\\colorbox[gray]{0.75}{\\parbox[c][\(height)][c]{\(width)}{\\begin{center}\(weekNumber)\\end{center}\\begin{center}\(text)\\end{center}}}}"
    }
}

struct ColumnHeader {
    let text: String
    
    init(_ t: String) {
        text = t
    }
    
    func emit() -> String {
        "\\multicolumn{1}{c}{\\textit{\(text)}}"
    }
}

struct TableHeader {
    let columnHeaders: [ColumnHeader]
    
    init(@TableHeaderBuilder _ columnHeadersFn: () -> [ColumnHeader]) {
        columnHeaders = columnHeadersFn()
    }

    func emit() -> String {
        let fmts = [String](repeating: "c", count: columnHeaders.count)
        let format = "\\begin{tabular}{|" + fmts.map { "@{}\($0)@{}" }.joined(separator: "|") + "|}"

        return format
            + "\n"
            + columnHeaders.map {
                $0.emit()
            }
            .joined(separator: "\n&")
            + "\\\\ \\hline"
    }
}


struct DayCell {

    let height: String
    let width: String
    let dayth: String   // short cardinal value of the day of the month, eg 1st, 2nd, 3rd
    let info: String    // very short lines of text
    let iconName: String
    let bgColor: Float  // 0..<1, smaller is darker
    
    init(day: Day, height: String = "1.8cm", width: String = "2.6cm") {
        
        self.height = height
        self.width = width
        
        self.bgColor = day.inSession ? 1.0 : 0.9
        self.dayth = Formatter.ordinal(day.dayOfMonth)
        
        if let e = day.events.first {
            self.info = e
        } else {
            self.info = ""
        }
        
        if !day.inSession {
            iconName = "noclass.png"
        } else {
            switch day.icon {
            case .Canvas:
                iconName = "canvas.png"
            case .Zoom:
                iconName = "zoom.png"
            default:
                iconName = "classroom.png"
                break
            }
        }
    }

    func emit() -> String {
        return """
            \\colorbox[gray]{\(bgColor)}{\\begin{minipage}[c][\(height)][t]{\(width)}\(dayth)\\raisebox{-2ex}{\\includegraphics[width=6mm,height=6mm,angle=0,center]{images/\(iconName)}}\\begin{center}\(info)\\end{center}
            \\end{minipage}}
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
        + " &\n"
        + cells.map {
            $0.emit()
        }
        .joined(separator: " &\n")
        + " \\\\ \\hline"
    }
}

struct Formatter {
    
    static let ordinalFormatter = NumberFormatter()
    
    static func ordinal(_ i: Int) -> String {
        ordinalFormatter.numberStyle = .ordinal
        return ordinalFormatter.string(from: NSNumber(integerLiteral: i))!
    }
}
