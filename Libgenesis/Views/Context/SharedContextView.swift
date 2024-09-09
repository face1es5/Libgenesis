//
//  SharedContextView.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import SwiftUI

struct SharedContextView: View {
    @EnvironmentObject var selBooksVM: BooksSelectionModel
    @ObservedObject var book: BookItem
    var selectedBooks: [BookItem] {
        selBooksVM.booksArr
    }
    var body: some View {
        Group {
            Button("Download \(book.truncTitle)") {
                DownloadManager.shared.download(book)
            }
            .keyboardShortcut("s")
            Button("Download Selected Books") {
                askDownload()
            }
            .disabled(selectedBooks.count == 0)
            .keyboardShortcut("j")
            if let links = book.details?.fileLinks {
                Divider()
                Menu("Download \(book.truncTitle) from") {
                    ForEach(links, id: \.self) { link in
                        DownloadButton(link, book: book)
                    }
                }
                .labelStyle(.titleAndIcon)
            }
        }
    }
    
    /// Handle a series of downloading.
    ///
    private func askDownload() {
        debugPrint("Download \(selectedBooks.map { $0.title })")
        DownloadManager.shared.download(Array(selectedBooks))
    }
    
    private func DownloadButton(_ link: URL, book: BookItem) -> some View {
        let m = DownloadMirror(link)
        return (
            Button {
                DownloadManager.shared.download(link, book: book)
            } label: {
                if m == .unknown {
                    Label(m.serverName, systemImage: "network")
                } else {
                    Label(m.serverName, image: m.rawValue.lowercased())
                }
            }
        )

    }
}

struct BookMarkMenuView: View {
    @ObservedObject var book: BookItem
    @EnvironmentObject var bookmarksManager: BookmarksModel
    var isBookmarked: Bool {
        bookmarksManager.contain(book)
    }
    var body: some View {
        Button(action: {
            if isBookmarked {
                bookmarksManager.remove(book)
            } else {
                bookmarksManager.insert(book)
            }
        }) {
            Label(isBookmarked ? "Remove bookmark" : "Add bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
        }
        .labelStyle(.titleAndIcon)
    }
}

struct SharedContextView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
