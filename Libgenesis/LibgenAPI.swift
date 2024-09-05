//
//  LibgenAPI.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import Foundation
import SwiftSoup

class LibgenAPI {
    static let shared = LibgenAPI()
    var baseURL: String
    private init() {
        baseURL = UserDefaults.standard.string(forKey: "baseURL")  ?? "what:????"
    }
    
    func parseTableHeader(_ ele: Element) throws -> [String] {
        var res: [String] = []
        try ele.select("tr td b").forEach { col in
//            print("\(col)")
            let val = try col.text()
            res.append(val)
        }
        return res
    }
    
    /// Parse book tag into array.
    ///
    /// [id, authors, title, publisher, year, pages, language, size, format, mirros, edit link]
    func parseTableContents(_ ele: Element, header: [String]) throws -> BookItem {
        var colIndex: Int = 0
        var id: String = "NON"
        var authors: String = "NON"
        var title: String = "NON"
        var publisher: String = "NON"
        var year: Int = 0
        var pages: Int = 0
        var language: String = "NON"
        var size: String = "NON"
        var format: String = "NON"
        var mirrors: [String] = []
        var edit: String = "NON"
        var edition: String = "NON"
        var isbn: String = "NON"
        var md5: String = "NON"
        var href: String = "NON"
        let md5reg = try NSRegularExpression(pattern: "md5=([A-Fa-f0-9]{32})")
        try ele.select("tr td").forEach { col in
            switch colIndex {
            case 0:
                id = try col.text()
                break;
            case 1: //authors
                authors = try col.text()
                break;
            case 2: //title, md5, and
                if let titleTag = try col.select("td a").first() {
                    title = try titleTag.text()
                    // extract md5
                    href = try titleTag.attr("href")
                    if let match = md5reg.firstMatch(in: href, options: [], range: NSRange(location: 0, length: href.utf16.count)) {
                        if let range = Range(match.range(at: 1), in: href) {
                            md5 = String(href[range])
                        }
                    }
                    // extract edtion and isbn
                    let fonts = try titleTag.select("a font")
                    if fonts.count == 2 {
                        edition = try fonts.get(0).text()
                        isbn = try fonts.get(1).text()
                    } else if fonts.count == 1 {
                        isbn = try fonts.get(0).text()
                    }
                }
                break;
            case 3:
                publisher = try col.text()
                break;
            case 4:
                year = try Int(col.text()) ?? 0
                break;
            case 5:
                pages = try Int(col.text()) ?? 0
                break;
            case 6:
                language = try col.text()
                break;
            case 7:
                size = try col.text()
                break;
            case 8:
                format = try col.text()
                break;
            case 9:
                mirrors = try col.text().components(separatedBy: ",")
                break;
            case 10:
                edit = try col.text()
                break;
                
            default:
                break;
            }
            colIndex += 1
        }
        return BookItem(id: id, authors: authors, title: title, publisher: publisher, year: year, pages: pages, language: language, size: size, format: format, mirrors: mirrors, edit: edit, md5: md5, href: href, isbn: isbn, edition: edition)
    }
    
    func latestBooks() async throws -> [BookItem] {
        let ht = try await APIService(to: baseURL+"/search.php?mode=last").getHtml()
        let doc: Document = try SwiftSoup.parse(ht)
        var tableHeader: [String] = []
        var books: [BookItem] = []
        if let bookeles = try doc.body()?.select("table.c").first()?.getElementsByTag("tbody").first() {
            var idx = 0
            for book in try bookeles.getElementsByTag("tr") {
                if idx == 0 {
                    tableHeader = try parseTableHeader(book)
                } else {
                    try books.append(parseTableContents(book, header: tableHeader))
                }
                idx += 1
            }
        }
        print("header: \(tableHeader)")
        return books
    }
    
}
