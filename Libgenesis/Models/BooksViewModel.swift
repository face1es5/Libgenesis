//
//  BooksViewModel.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import Foundation

class BooksViewModel: ObservableObject {
    @Published var books: [BookItem] = []
}

class BooksSelectionModel: ObservableObject {
    @Published var books = Set<BookItem>()
    var booksArr: [BookItem] {
        Array(books)
    }
    var firstBook: BookItem? {
        books.first
    }
    
    /// load selected books' details
    ///
    func loadDetails() {
        Task.detached(priority: .background) {
            print("Request details manully.")
            await withTaskGroup(of: Void.self) { taskGroup in
                for book in self.books {
                    if book.details == nil {
                        taskGroup.addTask {
                            await book.loadDetails()
                        }
                    }
                }
            }
        }
    }
    
    func clear() {
        books = []
    }
    
    func select(_ book: BookItem) {
        books = [book]
    }
}

