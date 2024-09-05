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
    let title: String
    let publisher: String
    let year: String
    let pages: String
    let language: String
    let size: String
    let format: String
    let mirrors: String
    let edit: String
    
    init(id: String, authors: String, title: String, publisher: String, year: String, pages: String, language: String, size: String, format: String, mirrors: String, edit: String) {
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
    }
}
