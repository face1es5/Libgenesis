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
    var coverURL: URL?
}

class BookItem: Identifiable, Hashable, Equatable, ObservableObject {
    static func == (lhs: BookItem, rhs: BookItem) -> Bool {
        return lhs.id == rhs.id && lhs.md5 == rhs.md5
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(id)\(md5)")
    }
    
    @Published var details: BookDetailsItem?
    let id: String
    let authors: String
    var authorSeqs: [String] {
        authors.components(separatedBy: ",")
    }
    let title: String
    var truncTitle: String
    let publisher: String
    let year: Int
    let pages: Int
    let language: String
    let size: String
    let format: String
    let mirrors: [URL]
    let edit: String
    let md5: String
    let href: URL?
    let isbn: String
    let edition: String
    var downloadLinks: [String] = []
    
    init(id: String, authors: String, title: String, publisher: String, year: Int, pages: Int, language: String, size: String, format: String, mirrors: [URL], edit: String, md5: String, href: URL?, isbn: String, edition: String) {
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
        self.href = href
        self.isbn = isbn
        self.edition = edition
        self.truncTitle = String(title.prefix(15))+"..."
    }
    
    func loadDetails() async {
        let bookDetails = try? await LibgenAPI.shared.parseBookDetails(md5, links: mirrors)
        await MainActor.run {
            self.details = bookDetails
        }
    }
}
