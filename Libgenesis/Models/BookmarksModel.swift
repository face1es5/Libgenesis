//
//  BookmarksModel.swift
//  Libgenesis
//
//  Created by Fish on 9/9/2024.
//

import Foundation

class BookmarksModel: ObservableObject {
    @Published var books: Set<BookItem> = Set<BookItem>() {
        didSet {
            save()
        }
    }
    
    var bookmarks: [BookItem] {
        Array(books)
    }
    
    init() {
        load()
    }
    
    func insert(_ book: BookItem) {
        books.insert(book)
    }
    
    func remove(_ book: BookItem) {
        books.remove(book)
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: "bookmarks")
        }
    }
    func load() {
        if let data = UserDefaults.standard.data(forKey: "bookmarks"),
           let decodedBooks = try? JSONDecoder().decode([BookItem].self, from: data) {
            self.books = Set(decodedBooks)
        }

    }
    func contain(_ book: BookItem) -> Bool {
        return books.contains(book)
    }
    
}




