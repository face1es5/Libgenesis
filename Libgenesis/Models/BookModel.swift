//
//  BookModel.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import Foundation

struct BookItem: Codable, Identifiable, Hashable {
    let id: String
    let authors: String
    var authorSeqs: [String] {
        authors.components(separatedBy: ",")
    }
    let title: String
    var truncTitle: String {
        if title.count <= 20 {
            return title
        } else {
            return String(title[..<title.index(title.startIndex, offsetBy: 17)])+"..."
        }
    }
    let publisher: String
    let year: Int
    let pages: Int
    let language: String
    let size: String
    let format: String
    let mirrors: [String]
    let edit: String
    let md5: String
    let href: String
    let isbn: String
    let edition: String
    
    init(id: String, authors: String, title: String, publisher: String, year: Int, pages: Int, language: String, size: String, format: String, mirrors: [String], edit: String, md5: String, href: String, isbn: String, edition: String) {
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
    }
}
