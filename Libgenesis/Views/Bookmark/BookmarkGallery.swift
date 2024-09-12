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
            LazyVStack {
                ForEach(bookmarks, id: \.self) { book in
                    BookMarkView(book: book)
                        .contextMenu {
                            BookMarkMenuView(book: book)
                            Divider()
                            SharedContextView(book: book)
                            
                        }
                }
            }
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}

struct BookMarkView: View {
    @ObservedObject var book: BookItem
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            CoverView
            TitleView
            Spacer()
        }
        .task {
            if book.details == nil {
                await book.loadDetails()
            }
        }
    }
    private var CoverView: some View {
        VStack {
            ImageView(url: book.details?.coverURL, width: 100, height: 161.8, cornerRadius: 10, defaultImg: "books.vertical.fill", breathing: true)
                .frame(width: 100, height: 161.8)
            
        }
    }
    private var TitleView: some View {
        VStack {
            if let detailURL = book.detailURL {
                Link(destination: detailURL) {
                    Text(book.title)
                        .lineLimit(2)
                }
            } else if let searchURL = book.searchURL {
                Link(destination: searchURL) {
                    Text(book.title)
                        .lineLimit(2)
                }
            } else {
                Text(book.title)
            }
        }
        .help(book.title)
        .font(.title2)
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
