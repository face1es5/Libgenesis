//
//  BookView.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import SwiftUI

struct BookLineView: View {
    @ObservedObject var book: BookItem
    @EnvironmentObject var booksVM: BooksViewModel
    @EnvironmentObject var selBooksVM: BooksSelectionModel
    var books: [BookItem] {
        booksVM.books
    }
    var selectedBooks: [BookItem] {
        selBooksVM.booksArr
    }

    var body: some View {
        Text(book.title)
            .contextMenu {
                SharedContextView(book: book)
                Divider()
                Button("Preview") {
                    fatalError("Preview to implemented.")
                }
            }
            .task {
                // try query details if there isn't.
                if book.details == nil {
                    // MARK: don't do this, may cause server block
//                    await book.loadDetails()
                }
            }
    }
    

    
}
