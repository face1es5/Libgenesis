//
//  BookModel.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import Foundation

struct BookDetailsItem: Codable, Equatable {
    var description: String
    var fileLinks: [URL] = []
}

struct AuthorItem: CustomStringConvertible, Codable {
    let name: String
    let url: URL?
    var description: String {
        name
    }
}

class BookItem: ObservableObject, Codable, Identifiable, Hashable, Equatable  {
    static func == (lhs: BookItem, rhs: BookItem) -> Bool {
        return lhs.id == rhs.id && lhs.md5 == rhs.md5
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(id)\(md5)")
    }
    
    @Published var details: BookDetailsItem?
    var coverURL: URL?
    /// TODO:
    let series: String = ""
    let tags: String = ""
    ///
    var text: String {
        "\(title) \(authorLiteral) \(id) \(publisher) \(year) \(series) \(isbn) \(language) \(md5) \(tags)"
    }
    let id: String
    var authors: [AuthorItem]
    var authorLiteral: String {
        var str = "\(authors)"
        if str.count == 0 {
            return "N/A"
        }
        str.removeFirst()
        str.removeLast()
        return str
    }
    let title: String
    var truncTitle: String
    let publisher: String
    let year: Int
    let pages: Int
    let language: String
    let size: String
    let format: String
    let mirrors: [URL]  // download page hrefs
    let edit: String
    let md5: String
    let detailURL: URL?    // detail URL of this book
    let searchURL: URL?  // URL to search this book
    let isbn: String    // ISBN number
    let edition: String
    var downloadLinks: [String] = []
    var loadingDetails: Bool = false
    
    init(id: String, authors: [AuthorItem], title: String, publisher: String, year: Int, pages: Int,
         language: String, size: String, format: String, mirrors: [URL], edit: String, md5: String,
         detailURL: URL?, searchURL: URL?, isbn: String, edition: String, coverURL: URL? = nil) {
        self.id = id
        self.authors = authors
        self.title = title
        self.publisher = publisher
        self.year = year
        self.pages = pages
        self.language = language
        self.size = size
        self.format = format
        self.mirrors = mirrors
        self.edit = edit
        self.md5 = md5
        self.detailURL = detailURL
        self.searchURL = searchURL
        self.isbn = isbn
        self.edition = edition
        self.truncTitle = String(title.prefix(15))+"..."
        self.coverURL = coverURL
    }
    
    func loadDetails() async {
        if loadingDetails {
            return
        }
        await MainActor.run {
            loadingDetails = true
        }
        var cnt = 1
        let maxRetry = 3
        while cnt <= maxRetry{
            if let details = await LibgenAPI.shared.parseBookDetails(book: self) {
                print("Load details of book \(truncTitle) succeed.")
                await MainActor.run {
                    self.details = details
                }
                break
            }
            try? await Task.sleep(for: .seconds(1)) // have a rest
            cnt += 1
        }
        
        await MainActor.run {
            loadingDetails = false
        }
    }
    
    // Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.authors = try container.decode([AuthorItem].self, forKey: .authors)
        self.title = try container.decode(String.self, forKey: .title)
        self.truncTitle = try container.decode(String.self, forKey: .truncTitle)
        self.publisher = try container.decode(String.self, forKey: .publisher)
        self.year = try container.decode(Int.self, forKey: .year)
        self.pages = try container.decode(Int.self, forKey: .pages)
        self.language = try container.decode(String.self, forKey: .language)
        self.size = try container.decode(String.self, forKey: .size)
        self.format = try container.decode(String.self, forKey: .format)
        self.mirrors = try container.decode([URL].self, forKey: .mirrors)
        self.edit = try container.decode(String.self, forKey: .edit)
        self.md5 = try container.decode(String.self, forKey: .md5)
        self.detailURL = try container.decodeIfPresent(URL.self, forKey: .detailHerf)
        self.searchURL = try container.decodeIfPresent(URL.self, forKey: .href)
        self.coverURL = try container.decodeIfPresent(URL.self, forKey: .coverURL)
        self.isbn = try container.decode(String.self, forKey: .isbn)
        self.edition = try container.decode(String.self, forKey: .edition)
        self.downloadLinks = try container.decode([String].self, forKey: .downloadLinks)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(authors, forKey: .authors)
        try container.encode(title, forKey: .title)
        try container.encode(truncTitle, forKey: .truncTitle)
        try container.encode(publisher, forKey: .publisher)
        try container.encode(year, forKey: .year)
        try container.encode(pages, forKey: .pages)
        try container.encode(language, forKey: .language)
        try container.encode(size, forKey: .size)
        try container.encode(format, forKey: .format)
        try container.encode(mirrors, forKey: .mirrors)
        try container.encode(edit, forKey: .edit)
        try container.encode(md5, forKey: .md5)
        try container.encodeIfPresent(detailURL, forKey: .detailHerf)
        try container.encodeIfPresent(searchURL, forKey: .href)
        try container.encodeIfPresent(coverURL, forKey: .coverURL)
        try container.encode(isbn, forKey: .isbn)
        try container.encode(edition, forKey: .edition)
        try container.encode(downloadLinks, forKey: .downloadLinks)
    }
}

extension BookItem {
    enum CodingKeys: String, CodingKey {
        case id, authors, title, truncTitle, publisher, year, pages, language, size, format, mirrors, edit, md5, detailHerf, href, coverURL, isbn, edition, downloadLinks
    }
}
