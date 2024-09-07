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
        var mirrors: [URL] = []
        var edit: String = "NON"
        var edition: String = "NON"
        var isbn: String = "NON"
        var md5: String = "NON"
        var hrefstr: String = "NON"
        var hrefURL: URL?
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
                    hrefstr = try titleTag.attr("href")
                    if let match = md5reg.firstMatch(in: hrefstr, options: [], range: NSRange(location: 0, length: hrefstr.utf16.count)) {
                        if let range = Range(match.range(at: 1), in: hrefstr) {
                            md5 = String(hrefstr[range])
                        }
                    }
                    // make href url
                    hrefURL = URL(string: "\(baseURL)/\(hrefstr)")
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
        return BookItem(id: id, authors: authors, title: title, publisher: publisher, year: year, pages: pages, language: language, size: size, format: format, mirrors: mirrors, edit: edit, md5: md5, href: hrefURL, isbn: isbn, edition: edition)
    }
    
    /// Parse description, download links, cover url
    ///
    func parseBookDetails(_ md5: String?, links: [URL]) async throws -> BookDetailsItem? {
        if md5 == nil {
            return nil
        }
        print("parse book details.")
        var desc: String = ""
        var coverURL: String = ""
        async let doc = try SwiftSoup.parse(try await APIService(to: "\(baseURL)/book/index.php?md5=\(md5!)").getHtml())
        async let urls = try parseDirectDownloadLinks(links)
        if let table = try await doc.body()?.select("table > tbody").first() {
            desc = try table.select("tr > td[colspan='4']").text()
            if let coverPath = try table.select("tr > td[rowspan='22'] > a[href] > img[src]").first()?.attr("src") {
                coverURL = "\(baseURL)/\(coverPath)"
            }
        }

        return try await BookDetailsItem(description: desc, fileLinks: urls, coverURL: URL(string: coverURL))
    }
    
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

    func queryBooks(url: URL?) async throws -> [BookItem] {
        guard
            let url = url
        else {
            throw APIError.nilURL
        }
        let ht = try await APIService(to: url).getHtml()
        let doc: Document = try SwiftSoup.parse(ht)
        var tableHeader: [String] = []
        var books: [BookItem] = []
        if let bookeles = try doc.body()?.select("table.c").first()?.getElementsByTag("tbody").first() {
            var idx = 0
            for book in try bookeles.getElementsByTag("tr") {
                if idx == 0 {
                    tableHeader = try parseTableHeader(book)
                } else {
                    books.append(try parseTableContents(book, header: tableHeader))
                }
                idx += 1
            }
        }
//        print("header: \(tableHeader)")
        return books
    }
    
    func search(_ searchStr: String, page: Int = 1) async throws -> [BookItem] {
        var query: [String: String] = [:]
        var pageN = page
        if searchStr.count >= 2 {
            pageN = 1
            query["req"] = searchStr
        } else {
            query["mode"] = "last"
        }
        query["page"] = "\(pageN)"
        return try await queryBooks(url: makeURL(baseURL: baseURL, path: "search.php", query: query))
    }
    
    func latestBooks(page: Int = 1) async throws -> [BookItem] {
        var query: [String: String] = [:]
        query["mode"] = "last"
        query["page"] = "\(page)"
        return try await queryBooks(url: makeURL(baseURL: baseURL, path: "search.php", query: query))
    }
    
    func makeURL(baseURL: String, path: String,  query: [String: String]) -> URL? {
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
