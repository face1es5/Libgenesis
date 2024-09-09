//
//  BookView.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import SwiftUI

/// Plain book line.
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
                Divider()
                BookMarkMenuView(book: book)
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

/// Book with cover
struct BookCoverView: View {
    @ObservedObject var book: BookItem
    var body: some View {
        HStack {
            CoverView
            BookLineView(book: book)
                .font(.title)
                .lineLimit(3)
                .task(priority: .background) {
                    if book.details == nil {
                        await book.loadDetails()
                    }
                }
        }
    }
    
    private var CoverView: some View {
        VStack {
            ImageView(url: book.details?.coverURL, width: 92.55, height: 150, cornerRadius: 15, defaultImg: "a.book.closed.fill.zh", breathing: true)
                .frame(width: 92.55, height: 150)
        }
    }
}
