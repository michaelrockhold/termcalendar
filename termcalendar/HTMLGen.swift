//
//  HTMLGen.swift
//  termcalendar
//
//  Created by Michael Rockhold on 1/23/22.
//

import Foundation

struct HTMLGen: Generator {
    typealias Style = HTMLStyle
    typealias Document = HTMLDocument
    typealias Head = HTMLHead
    typealias Body = HTMLBody
    typealias Footer = HTMLFooter
    typealias H = HTMLH
    typealias BR = HTMLBR
    typealias P = HTMLP
    typealias Table = HTMLTable
    typealias TableHeader = HTMLTableHeader
    typealias TableCell = HTMLTableCell
    typealias ColumnHeader = HTMLColumnHeader
    typealias TableRow = HTMLTableRow
    typealias RowHeader = HTMLRowHeader
    typealias Img = HTMLImg

    func document(head: Head, body: Body, footer: Footer) -> Document {
        return Document(head: head, body: body, footer: footer)
    }
    
    func head() -> Head { Head() }
    
    func body(content: () -> [Element]) -> Body { Body(contents: content()) }
    
    func footer() -> Footer { Footer() }
    
    func h(level: Int, text: String) -> H { H(level: level, text: text) }
    
    func br() -> BR { BR() }
    
    func p() -> P { P() }
    
    func img(_ icon: Day.Icon, width: Int, height: Int) -> HTMLImg {
        Img(icon, width: width, height: height)
    }
    
    func table(header: Self.TableHeader, rows rfn: () -> [TableRow]) -> Table {
        Table(header: header, rows: rfn())
    }
    
    func tableHeader(columnHeaders: () -> [ColumnHeader]) -> HTMLTableHeader {
        TableHeader(columnHeaders: columnHeaders())
    }
    
    func columnHeader(_ text: String) -> ColumnHeader {
        ColumnHeader(text: text)
    }
    
    func rowHeader(klass: String?, content: () -> [Element]) -> RowHeader {
        RowHeader(klass: klass, contents: content())
    }
    
    func tableRow(header: HTMLRowHeader, tableCells: () -> [TableCell]) -> TableRow {
        TableRow(header: header, rows: tableCells())
    }
    
    func tableCell(klass: String, contents: () -> [Element]) -> TableCell {
        TableCell(klass: klass, contents: contents())
    }
}

struct HTMLDocument: Document_ {
    typealias G = HTMLGen
    
    let docType = "html"
    let head: G.Head
    let body: G.Body
    let footer: G.Footer
    
    func emit() -> String {
        return "<!DOCTYPE \(docType)><html>"
        + head.emit()
        + body.emit()
        + footer.emit()
        + "</html>"
    }
}

struct HTMLStyle: Style_ {
    let directive: String
    
    init(_ d: String) {
        directive = d
    }
    
    func emit() -> String {
        return directive
    }
}


struct HTMLHead: Head_ {
    typealias G = HTMLGen
    
    let styles: [G.Style]

    init(content: () -> [HTMLStyle]) {
        styles = content()
    }
    
    
    init() {
        styles = [
                """
                table, th, td {
                    border: 1px solid black;
                }
                """,
                """
                .noClassDay {
                    background-color: lightgrey;
                    text-align:center;
                    width: 100px;
                    height: 60px;
                }
                """,
                """
                .classDay {
                    background-color: white;
                    text-align:center;
                    width: 100px;
                    height: 60px;
                }
                """,
                """
                .rowHeader {
                    background-color: darkgrey;
                    text-align:center;
                    width: 90px;
                    height: 60px;
                }
                """
        ].map { HTMLStyle($0) }
    }
        
    func emit() -> String {
        return "<head>\n"
        + "<style>\n"
        + self.styles.map { style in
            style.emit()
        }
        .joined(separator: "\n")
        + "\n</style>"
        + "\n</head>"
    }
}

struct HTMLFooter: Footer_ {
    func emit() -> String {
        ""
    }
}

struct HTMLBody: Body_ {
    
    let contents: [Element]
    
    init(contents: [Element]) {
        self.contents = contents
    }
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


struct HTMLH: H_ {
    let level: Int
    let text: String
    
    func emit() -> String {
        return "<h\(level)>\(text)</h\(level)>"
    }
}

struct HTMLBR: BR_ {
    func emit() -> String { "<br/>\n" }
}

struct HTMLP: P_ {
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


struct HTMLTable: Table_ {
    typealias G = HTMLGen

    let header: G.TableHeader
    let rows: [G.TableRow]
    
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


struct HTMLRowHeader: RowHeader_ {

    let klass: String?
    let contents: [Element]
    
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

struct HTMLColumnHeader: ColumnHeader_ {
    
    let text: String
    
    func emit() -> String {
        "<th scope=\"col\">\(text)</th>"
    }
}

struct HTMLTableHeader: TableHeader_ {
    typealias G = HTMLGen

    let columnHeaders: [G.ColumnHeader]
    
    func emit() -> String {
        return "<TR>"
        + columnHeaders.map {
            $0.emit()
        }
        .joined(separator: "")
        + "</TR>"
    }
}

struct HTMLTableCell: TableCell_ {
    let klass: String?
    let contents: [Element]
    
    func emit() -> String {
        return (klass == nil ? "<TD>" : "<TD class=\"\(klass!)\">")
        + contents.map {
            $0.emit()
        }
        .joined(separator: "")
        + "</TD>"
    }
}

struct HTMLTableRow: TableRow_ {
    typealias G = HTMLGen

    let header: G.RowHeader
    var rows: [G.TableCell]
    
    func emit() -> String {
        return "<TR>"
        + header.emit()
        + rows.map {
            $0.emit()
        }
        .joined(separator: "")
        + "</TR>"
    }
}

struct HTMLImg: Img_ {
    typealias G = HTMLGen

    let src: String
    let alt: String
    let width: Int
    let height: Int
    
    static func icon(for icon: Day.Icon) -> (String,String) {
        switch icon {
        case .Canvas:
            return ("data:image/png;base64,\(canvasIconBase64)==", "Canvas sesssion")
        case .Zoom:
            return ("data:image/png;base64,\(zoomIconBase64)==", "Zoom class")
        }
    }

    init(_ icon: Day.Icon, width w: Int, height h: Int) {
        (src, alt) = HTMLImg.icon(for: icon)
        width = w
        height = h
    }
    
    func emit() -> String {
        return "<img src=\"\(src)\" alt=\"\(alt)\" width=\"\(width)\" height=\"\(height)\" />"
    }
}
