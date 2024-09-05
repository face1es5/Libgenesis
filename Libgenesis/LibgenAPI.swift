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
    func parseTableContents(_ ele: Element) throws -> BookItem {
        var res: [String] = []
        try ele.select("tr td").forEach { col in
            let val = try col.text()
            res.append(val)
        }
        return BookItem(id: res[0], authors: res[1], title: res[2], publisher: res[3], year: res[4], pages: res[5], language: res[6], size: res[7], format: res[8], mirrors: res[9], edit: res[10])
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
                    try books.append(parseTableContents(book))
                }
                idx += 1
            }
        }
        print("header: \(tableHeader)")
        return books
    }
    
}
