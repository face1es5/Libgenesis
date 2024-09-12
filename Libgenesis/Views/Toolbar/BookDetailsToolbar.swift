//
//  BookDetailsToolbar.swift
//  Libgenesis
//
//  Created by Fish on 9/9/2024.
//

import SwiftUI

struct BookDetailsToolbar: View {
    @AppStorage("bookDetailsDisplayMode") var displayMode: BookDetailsDislayMode = .common
    @EnvironmentObject var booksSel: BooksSelectionModel
    @EnvironmentObject var bookmarkManager: BookmarksModel
    
    var book: BookItem? {
        booksSel.firstBook
    }
    
    var body: some View {
        HStack {
            Picker("Display mode", selection: $displayMode) {
                ForEach(BookDetailsDislayMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.inline)
            .help("Display book info in complex/detail/simple mode.")
            
            Button(action: {
                Task.detached(priority: .background) {
                    await askDownload()
                }
            }) {
                Image(systemName: "icloud.and.arrow.down.fill")
                    .foregroundColor(booksSel.firstBook == nil ? .gray : .blue)
            }
            .disabled(booksSel.firstBook == nil)
            .help("Click to download this book.")
            
            Button(action: {
                toggleBookmark()
            }) {
                Image(systemName: isBookmarked() ? "bookmark.fill" : "bookmark")
                    .foregroundColor(booksSel.firstBook == nil ? .gray : .blue)
            }
            .disabled(booksSel.firstBook == nil)
            .help("Click to add/remove bookmark.")
            
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

struct BookDetailsToolbar_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailsToolbar()
    }
}
