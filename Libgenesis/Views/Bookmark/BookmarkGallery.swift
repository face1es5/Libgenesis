//
//  BookmarksView.swift
//  Libgenesis
//
//  Created by Fish on 10/9/2024.
//

import SwiftUI

struct BookmarkGallery: View {
    @EnvironmentObject var bookmarksManager: BookmarksModel
    var bookmarks: [BookItem] {
        bookmarksManager.bookmarks
    }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(bookmarks, id: \.self) { book in
                    BookMarkView(book: book)
                }
            }
        }
        .padding()
    }
}

struct BookMarkView: View {
    @ObservedObject var book: BookItem
    var body: some View {
        BookCoverView(book: book)
            .contextMenu {
                BookMarkMenuView(book: book)
            }
        Divider()
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
