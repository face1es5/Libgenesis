//
//  LibgenAPI.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import Foundation
import SwiftSoup
import Alamofire

class LibgenAPI {
    static let shared = LibgenAPI()

    var baseURL: String {
        UserDefaults.standard.string(forKey: "baseURL")  ?? "what:????"
    }
    var perPageN: Int {
        UserDefaults.standard.integer(forKey: "perPageN")
    }
    
    /// TODO: auto switch mirror if current mirror could be unavailable(reach maximum retry times).
    let mutex = NSLock()
    let maxRetryN = 10          // maximum retry times
    let currentRetryTimes = 0   // current retry times
    private func autoSwitch() {
        fatalError("Implement auto switch operations.")
    }
    /// End
    
    private init() {
        //...
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
        var colIndex: Int = 0
        var id: String = "N/A"
        var authors: String = "N/A"
        var title: String = "N/A"
        var publisher: String = "N/A"
        var year: Int = 0
        var pages: Int = 0
        var language: String = "N/A"
        var size: String = "N/A"
        var format: String = "N/A"
        var mirrors: [URL] = []
        var edit: String = "N/A"
        var edition: String = "N/A"
        var isbn: String = "N/A"
        var md5: String = "N/A"
        var hrefstr: String = "N/A"
        var searchURL: URL?
        var detailURL: URL?
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
                if let titleTag = try col.select("td a[id=\(id)]").first() {
                    title = try titleTag.text()
                    // extract md5
                    hrefstr = try titleTag.attr("href")
                    if let match = md5reg.firstMatch(in: hrefstr, options: [], range: NSRange(location: 0, length: hrefstr.utf16.count)) {
                        if let range = Range(match.range(at: 1), in: hrefstr) {
                            md5 = String(hrefstr[range])
                            // if md5 valid, then parse detail url of this book
                            detailURL = makeURL(baseURL: baseURL, path: "book/index.php", query: ["md5": "\(md5)"])
                        }
                    }
                    // make href url
                    searchURL = URL(string: "\(baseURL)/\(hrefstr)")
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
            case 9, 10:
                let urlstr = try col.getElementsByTag("a").attr("href")
                if let url = URL(string: urlstr) {
                    mirrors.append(url)
                }
                break;
            case 11:
                edit = try col.text()
                break;
                
            default:
                break;
            }
            colIndex += 1
        }
        return BookItem(
            id: id, authors: authors, title: title, publisher: publisher, year: year,
            pages: pages, language: language, size: size, format: format, mirrors: mirrors, edit: edit,
            md5: md5, detailURL: detailURL, searchURL: searchURL, isbn: isbn, edition: edition)
    }
    
    /// Parse description, download links, cover url
    ///
    /// - Parameters:
    ///   - book: Book to load details( 2 field needed, firstly is detail url, second is mirror urls
    /// - Returns: details item
    func parseBookDetails(book: BookItem) async throws -> BookDetailsItem? {
        #if DEBUG
        print("parse book details of \(book.truncTitle)")
        #endif
        guard
            let url = book.detailURL
        else {
            print("Parse book \(book.truncTitle) details failed: nil book url")
            return nil
        }
        var desc: String = "N/A"
        var coverURL: String = ""
        async let doc = try SwiftSoup.parse(try await APIService(to: url).getHtml())
        async let urls = try parseDirectDownloadLinks(book.mirrors)
        if let table = try await doc.body()?.select("table > tbody").first() {
            desc = try table.select("tr > td[colspan='4']").text()
            if let coverPath = try table.select("tr > td[rowspan='22'] > a[href] > img[src]").first()?.attr("src") {
                coverURL = "\(baseURL)/\(coverPath)"
            }
        }

        return try await BookDetailsItem(description: desc, fileLinks: urls, coverURL: URL(string: coverURL))
    }
    
    /// Parse downloadl url of book
    /// - Parameter links: mirror links
    /// - Returns: direct download urls of these links.
    func parseDirectDownloadLinks(_ links: [URL]) async throws -> [URL] {
        var urls: [URL] = []
        for url in links {
            let doc = try SwiftSoup.parse(try await APIService(to: url).getHtml())
            if try doc.body()?.select("div[role='alert']").first()?.text() == "File not found in DB" {   // invalid response
                continue
            } else {
                try doc.body()?.getElementById("download")?.select("h2 > a[href], ul > li > a[href]").forEach { atag in
                    if let fileLink = try? URL(string: atag.attr("href")) {
                        urls.append(fileLink)
                    }
                }
            }
        }
        return urls
    }

    /// Helper function for query a series of books, get lastest books or search books
    func queryBooks(url: URL?) async throws -> [BookItem] {
        guard
            let url = url
        else {
            throw APIError.nilURL
        }
        let ht = try await APIService(to: url).getHtml()
        let doc: Document = try SwiftSoup.parse(ht)
        #if DEBUG
        var tableHeader: [String] = []
        #endif
        var books: [BookItem] = []
        if let bookeles = try doc.body()?.select("table.c").first()?.getElementsByTag("tbody").first() {
            var idx = 0
            for book in try bookeles.getElementsByTag("tr") {
                if idx == 0 {
                    #if DEBUG
                    tableHeader = try parseTableHeader(book)
                    #endif
                } else {
                    books.append(try parseTableContents(book))
                }
                idx += 1
            }
        }
        #if DEBUG
//        print("header: \(tableHeader)")
        #endif
        return books
    }
    
    /// Search for books
    /// - Parameters:
    ///   - searchStr: search string, emit when string len less than 2.
    ///   - page: page offset, default 1.
    ///   - col: column filter, see enum ColumnFilter.
    /// - Returns: a list of books
    func search(_ searchStr: String, page: Int = 1, col: ColumnFilter = .def, formats: Set<FormatFilter> = [.def]) async throws -> [BookItem] {
        var query: [String: String] = [:]
        if searchStr.count >= 2 {   // search for specific books
            query["req"] = searchStr
        } else {    // lastest books
            query["mode"] = "last"
        }
        // page offset
        query["page"] = "\(page)"
        // results num
        query["res"] = "\(perPageN)"
        // column filter
        query["column"] = col.queryKey
        
        let books = try await queryBooks(url: makeURL(baseURL: baseURL, path: "search.php", query: query))
        
        return filter(books, formats: formats)
    }
    
    
    /// Filter after querying, .i.e filter books locally.
    /// - Parameter formats: format filters
    /// - Returns: filtered books
    func filter(_ books: [BookItem], formats: Set<FormatFilter> = [.def]) -> [BookItem] {
        if formats.count == 0 { // no filters
            return books
        } else if formats.count == 1, formats.contains(.def) { // default, just return original data.
            return books
        }
        return books.filter { book in
            if let format = FormatFilter(rawValue: book.format) {
                return formats.contains(format)
            }
            return false
        }
    }
    
    /// TODO: Chain-like filter on remote server
    ///
    /// - Parameters:
    ///   - searchStr: search string.
    ///   - page: page offset.
    ///   - query: url queries.
    /// - Returns: list of books.
    ///
    func advanceSearch(_ searchStr: String, page: Int = 1, query: [String: String]) async throws -> [BookItem] {
        fatalError("Implement advance search.")
        return try await queryBooks(url: makeURL(
            baseURL: baseURL, path: "search.php",
            query: query
        ))
    }
    
    func latestBooks(page: Int = 1) async throws -> [BookItem] {
        var query: [String: String] = [:]
        query["mode"] = "last"
        query["page"] = "\(page)"
        return try await queryBooks(url: makeURL(baseURL: baseURL, path: "search.php", query: query))
    }
    
    func makeURL(baseURL: String, path: String, query: [String: String]) -> URL? {
        guard
            var url = URLComponents(string: "\(baseURL)/\(path)")
        else {
            return nil
        }
        url.queryItems = query.map { k, v in URLQueryItem(name: k, value: v) }
        return url.url
    }
    
    /// Get file size of url by content length.
    func fileSize(url: URL, completion: @escaping (Int64?) -> Void) {
        AF.request(url, method: .head).response { resp in
            if let totalBytes = resp.response?.expectedContentLength {
                completion(totalBytes)
            } else {
                completion(nil)
            }
        }
    }
}
