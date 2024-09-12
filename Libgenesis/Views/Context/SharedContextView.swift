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
            Button("Download") {
                Task.detached(priority: .background) {
                    await askDownload(book)
                }
            }
            .keyboardShortcut("s")
            Button("Download Selected Books") {
                Task.detached(priority: .background) {
                    await askDownload()
                }
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
    
    /// Handle download targe book.
    private func askDownload(_ book: BookItem) async {
        if book.details == nil {
            await book.loadDetails()
        }
        DownloadManager.shared.download(book)
    }
    
    /// Handle a series of downloading.
    private func askDownload() async {
        for bk in selectedBooks {
            if bk.details == nil {
                await bk.loadDetails()
            }
        }
        print("Download \(selectedBooks.map { $0.title })")
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
        Group {
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
            
            Button(action: {
                Task.detached(priority: .background) {
                    await book.loadDetails()
                }
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .labelStyle(.titleAndIcon)
        }
    }

}

struct SharedContextView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
