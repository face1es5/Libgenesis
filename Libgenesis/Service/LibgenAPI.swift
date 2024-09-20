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
        UserDefaults.standard.string(forKey: "baseURL")  ?? ServerMirror.defaultMirror.url.absoluteString
    }
    var perPageN: Int {
        UserDefaults.standard.integer(forKey: "perPageN")
    }
    
    private init() {
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
        var authors: [AuthorItem] = []
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
                try col.select("a[href]").forEach { au in
                    if let author = try? AuthorItem(name: au.text(), url: URL(string: "\(baseURL)/\(au.attr("href").urlEncode())")) {
                        authors.append(author)
                    }
                }
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
    
    func queryBooksWithCover(url: URL?) async throws -> [BookItem] {
        guard
            let url = url
        else {
            throw APIError.nilURL
        }
        let ht = try await APIService(to: url).getHtml()
        let doc: Document = try SwiftSoup.parse(ht)
        var books: [BookItem] = []
        do {
            try doc.select("table[border='0'][rules='cols'][width='100%'] > tbody").forEach { item in
                if let book = try? parseTableWithCover(item) {
                    books.append(book)
                }
            }
        } catch {
            print("\(error)")
        }
        return books
    }
    
    func parseTableWithCover(_ ele: Element) throws -> BookItem? {
        var coverURL: URL?
        var colIndex: Int = 0
        var id: String = "N/A"
        var authors: [AuthorItem] = []
        var series: String = "N/A"
        var periodical: String = "N/A"
        var title: String = "N/A"
        var publisher: String = "N/A"
        var year: Int = 0
        var pages: Int = 0
        var language: String = "N/A"
        var size: String = "N/A"
        var format: String = "N/A"
        var mirrors: [URL] = []
        let edit: String = "N/A"
        let edition: String = "N/A"
        var isbn: String = "N/A"
        var md5: String = "N/A"
        var searchURL: URL?
        var detailURL: URL?
        let md5reg = /md5=([A-Fa-f0-9]{32})/
        
        try ele.select("tr").forEach { col in
            switch colIndex {
            case 0:
                break
            case 1: //md5, mirror, detail url, cover url, title
                if let mirror = try? URL(string: "\(baseURL)\(col.select("a").attr("href"))") {
                    mirrors.append(mirror)
                    if let match = try md5reg.firstMatch(in: mirror.absoluteString) {
                        md5 = "\(match.1)"
                        detailURL = makeURL(baseURL: baseURL, path: "book/index.php", query: ["md5": "\(md5)"])
                        let m2 = URL(string: "http://libgen.li/ads.php?md5=\(md5)")
                        assert(m2 != nil, "Parse error: mirror 2 is nil URL.")
                        mirrors.append(m2!)
                    }
                }
                coverURL = try? URL(string: "\(baseURL)\(col.select("img").attr("src"))")
                title = try col.select("td[colspan='2'] > b > a").text()
                break
            case 2: // author
                try col.select("a[href]").forEach { au in
                    if let author = try? AuthorItem(name: au.text(), url: URL(string: "\(baseURL)/\(au.attr("href").urlEncode())")) {
                        authors.append(author)
                    }
                }
                break
            case 3:
                series = try col.select("td").get(1).text()
                periodical = try col.select("td").get(3).text()
                break
            case 4:
                publisher = try col.select("td").get(1).text()
                break
            case 5:
                year = try Int(col.select("td").get(1).text()) ?? 0
                break
            case 6:
                language = try col.select("td").get(1).text()
                pages = try Int(col.select("td").get(3).text()) ?? 0
                break
            case 7: // isbn, id
                isbn = try col.select("td").get(1).text()
                id = try col.select("td").get(3).text()
                break
            case 8: // add date and modify date
                break
            case 9:
                let sizereg = /([\d]+\s[GgMmKk][Bb])\s\([\d]+\)/
                if let sz = try sizereg.firstMatch(in: col.select("td").get(1).text()) {
                    size = "\(sz.1)"
                }
                format = try col.select("td").get(3).text()
                break
            case 10:    //bibtex
                break
            case 11:    //topic
                break
            case 12:    //mirrors seems invalid
                break
            default:
                break
            }
            colIndex += 1
        }
        
        if id == "N/A" {
            return nil
        }
        
        return BookItem(
            id: id, authors: authors, title: title, publisher: publisher, year: year,
            pages: pages, language: language, size: size, format: format, mirrors: mirrors, edit: edit,
            md5: md5, detailURL: detailURL, searchURL: searchURL, isbn: isbn, edition: edition, coverURL: coverURL)
    }
    
    /// Parse description, download links, cover url
    ///
    /// - Parameters:
    ///   - book: Book to load details( 2 field needed, firstly is detail url, second is mirror urls
    /// - Returns: details item
    func parseBookDetails(book: BookItem) async -> BookDetailsItem? {
        #if DEBUG
        print("parse book details of \(book.truncTitle)")
        #endif
        do {
            async let urls = try parseDirectDownloadLinks(book.mirrors)
            async let desc: String = {
                guard let url = book.detailURL else { return "N/A" }
                let doc = try await SwiftSoup.parse(APIService(to: url).getHtml())
                return try doc.body()?.select("table > tbody").first()?.select("tr > td[colspan='4'][style]").text() ?? "Book descripition is not available."
            }()

            return try await BookDetailsItem(description: desc, fileLinks: urls)
        } catch {
            print("Load details of book \(book.truncTitle) failed: \(error.localizedDescription)")
        }
        return nil
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
        var books: [BookItem] = []
        if let bookeles = try doc.body()?.select("table.c").first()?.getElementsByTag("tbody").first() {
            var idx = 0
            for book in try bookeles.getElementsByTag("tr") {
                if idx > 0 {
                    books.append(try parseTableContents(book))
                    idx += 1
                }
            }
        }
        return books
    }
    
    /// Search for books
    /// - Parameters:
    ///   - searchStr: search string, emit when string len less than 2.
    ///   - page: page offset, default 1.
    ///   - col: column filter, see enum ColumnFilter.
    /// - Returns: a list of books
    func search(_ searchStr: String, page: Int = 1, col: ColumnFilter = .def,
                formats: Set<FormatFilter> = [.all], topic: Int = 0) async throws -> [BookItem] {
        var query: [String: String] = [:]

        if topic > 0 {
            if searchStr.count > 0 {
                query["req"] = "topicid\(topic)-\(searchStr)"
            } else {
                query["req"] = "topicid\(topic)"
            }
        } else {
            query["req"] = searchStr
        }
        
        // page offset
        query["page"] = "\(page)"
        // results num
        query["res"] = "\(perPageN)"
        // column filter
        query["column"] = col.queryKey
        // cover mode
        query["view"] = "detailed"
        
        let books = try await queryBooksWithCover(url: makeURL(baseURL: baseURL, path: "search.php", query: query))
        
        return filter(books, formats: formats)
    }
    
    /// Parse fiction book
    func parseFiction(_ ele: Element) throws -> BookItem? {
        let coverURL: URL? = nil
        var colIndex: Int = 0
        var id: String = "N/A"
        var authors: [AuthorItem] = []
        var series: String = "N/A"
        let periodical: String = "N/A"
        var title: String = "N/A"
        let publisher: String = "N/A"
        let year: Int = 0
        let pages: Int = 0
        var language: String = "N/A"
        var size: String = "N/A"
        var format: String = "N/A"
        var mirrors: [URL] = []
        let edit: String = "N/A"
        let edition: String = "N/A"
        var isbn: String = "N/A"
        var md5: String = "N/A"
        let searchURL: URL? = nil
        var detailURL: URL?
        let md5reg = /fiction\/([A-Fa-f0-9]{32})/
        let filereg = /(\w+)\s\/\s([\d\.]+\s\w+)/
        
        try ele.select("td").forEach { col in
            switch colIndex {
            case 0: //authors
                if let au = try? col.getElementsByTag("a").first(),
                   let name = try? au.text(),
                   let url = try? URL(string: "\(baseURL)\(au.attr("href"))") {
                    authors.append(AuthorItem(name: name, url: url))
                }
                break
            case 1: //series
                series = try col.text()
                break
            case 2: //title, detail url, md5, isbn?
                if let atag = try? col.select("p > a").first() {
                    title = try atag.text()
                    let href = try atag.attr("href")
                    detailURL = URL(string: "\(baseURL)\(href)")
                    if let match = try md5reg.firstMatch(in: href) {
                        md5 = "\(match.1)"
                    }
                }
                if let str = try? col.select("p.catalog_identifier").text(),
                   let match = try /ISBN:\s([\d]+)/.firstMatch(in: str) {
                    isbn = "\(match.1)"
                }
                break
            case 3: //language
                language = try col.text()
                break
            case 4: //format, size
                if let match = try filereg.firstMatch(in: col.text()) {
                    format = "\(match.1)".lowercased()
                    size = "\(match.2)"
                }
                break
            case 5: //mirrors
                try col.getElementsByTag("a").forEach { atag in
                    if let href = try? atag.attr("href"),
                       let url = URL(string: href) {
                        mirrors.append(url)
                    }
                }
                id = UUID().uuidString
                break
            case 6: //edit
                break
            default:
                break
            }
            colIndex += 1
        }
        
        if id == "N/A" {
            return nil
        }
        
        return BookItem(
            id: id, authors: authors, title: title, publisher: publisher, year: year,
            pages: pages, language: language, size: size, format: format, mirrors: mirrors, edit: edit,
            md5: md5, detailURL: detailURL, searchURL: searchURL, isbn: isbn, edition: edition, coverURL: coverURL)
    }
    
    /// Parse fiction records from a table
    func parseFictions(url: URL?) async throws -> [BookItem] {
        guard let url = url
        else {
            throw APIError.nilURL
        }
        let doc = try await SwiftSoup.parse(APIService(to: url.absoluteString).getHtml())
        var books: [BookItem] = []
        do {
            try doc.select("table.catalog > tbody > tr").forEach { item in
                if let book = try? parseFiction(item) {
                    books.append(book)
                }
            }
        } catch {
            print("\(error)")
        }
        return books
    }
    
    /// Search fictions
    func searchFiction(_ searchStr: String, page: Int = 1, formats: Set<FormatFilter> = [.all]) async throws -> [BookItem] {
        let query: [String: String] = ["q": searchStr, "page": "\(page)"]
        let books = try await parseFictions(url: makeURL(baseURL: baseURL, path: "fiction", query: query))
        
        return filter(books, formats: formats)
    }
    
    /// Filter after querying, .i.e filter books locally.
    /// - Parameter formats: format filters
    /// - Returns: filtered books
    func filter(_ books: [BookItem], formats: Set<FormatFilter> = [.all]) -> [BookItem] {
        if formats.count == 0 { // no filters
            return books
        } else if formats.count == 1, formats.contains(.all) { // default, just return original data.
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
    
    func makeURL(baseURL: String, path: String, query: [String: String] = [:]) -> URL? {
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
    
    func checkConn(_ url: URL) async -> Bool {
        guard let req = try? URLRequest(url: url, method: .head)
        else {
            print("Libgenesis.LibgenAPI.checkConn(URL): Create Request Failed.")
            return false
        }
        let maxRetry = 3
        var cnt = 1
        while cnt <= maxRetry {
            do {
                let (_, resp) = try await URLSession.shared.data(for: req)
                if let httpResp = resp as? HTTPURLResponse,
                   (200...299) ~= httpResp.statusCode {
                    print("Server: \(url) is online.")
                    return true
                }
            } catch {
                print("Libgenesis.LibgenAPI.checkConn(URL): Request failed with: \(error.localizedDescription)")
            }
            cnt += 1
            do {
                try await Task.sleep(for: .seconds(1))  // have a rest before retry
            } catch {
                print("\(error)")
            }
        }
        // failed as reached limit retry times.
        print("Server: \(url) is not online.")
        return false
    }
    
    func checkConn(_ urlStr: String) async -> Bool {
        guard let url = URL(string: urlStr)
        else {
            print("Libgenesis.LibgenAPI.checkConn(\(urlStr): Invalid URL.")
            return false
        }
        return await checkConn(url)
    }
}

