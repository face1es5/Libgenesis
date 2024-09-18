//
//  BookDetailsToolbar.swift
//  Libgenesis
//
//  Created by Fish on 9/9/2024.
//

import SwiftUI

struct BookDetailsToolbar: View {
    @EnvironmentObject var booksSel: BooksSelectionModel
    @EnvironmentObject var bookmarkManager: BookmarksModel
    var book: BookItem? {
        booksSel.firstBook
    }
    
    var body: some View {
        Group {
            Spacer()
            
            Button(action: {
                toggleBookmark()
            }) {
                Image(systemName: isBookmarked() ? "bookmark.fill" : "bookmark")
            }
            .disabled(booksSel.firstBook == nil)
            .help("Click to add/remove bookmark.")

            Button(action: {
                Task.detached(priority: .background) {
                    await askDownload()
                }
            }) {
                Image(systemName: "square.and.arrow.down.on.square.fill")
            }
            .disabled(booksSel.firstBook == nil)
            .help("Click to download this book.")
        }
    }
    
    private func isBookmarked() -> Bool {
        guard let book = booksSel.firstBook else { return false }
        return bookmarkManager.contain(book)
    }
    
    private func toggleBookmark() {
        guard let book = booksSel.firstBook else { return }
        if bookmarkManager.contain(book) {
            bookmarkManager.remove(book)
        } else {
            bookmarkManager.insert(book)
        }
    }
    
    /// Handle download targe book.
    private func askDownload() async {
        guard let book = booksSel.firstBook else { return }
        if book.details == nil {
            await book.loadDetails()
        }
        DownloadManager.shared.download(book)
    }
}

struct BookDetailsBottomToolBar: View {
    @AppStorage("bookDetailsDisplayMode") var displayMode: BookDetailsDislayMode = .common
    
    var body: some View {
        HStack {
            Picker("", selection: $displayMode) {
                ForEach(BookDetailsDislayMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .frame(width: 180)
            .labelStyle(.iconOnly)
            .pickerStyle(.segmented)
            .help("Display book info in complex/detail/simple mode.")
        }
    }
    
}

struct BookDetailsToolbar_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailsToolbar()
    }
}
