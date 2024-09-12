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

    var body: some View {
        Text(book.title)
            .contextMenu {
                BookContext(book: book)
            }
    }
    
}

struct BookContext: View {
    @ObservedObject var book: BookItem
    var body: some View {
        Group {
            Button("Refresh") {
                Task.detached(priority: .background) {
                    await book.loadDetails()
                }
            }
            Divider()
            SharedContextView(book: book)
            Divider()
            Button("Preview") {
                fatalError("Preview to implemented.")
            }
            Divider()
            BookMarkMenuView(book: book)
        }
    }
}

struct BookView: View {
    @ObservedObject var book: BookItem
    let mode: BookLineDisplayMode
    init(_ book: BookItem, mode: BookLineDisplayMode) {
        self.book = book
        self.mode = mode
    }
    var body: some View {
        if mode == .list {
            BookLineView(book: book)
        } else if mode == .gallery {
            BookCoverView(book: book)
        }
    }
}

/// Book with cover
struct BookCoverView: View {
    @ObservedObject var book: BookItem
    var body: some View {
        HStack(spacing: 20) {
            CoverView
            VStack(alignment: .leading, spacing: 5) {
                Text(book.title)
                    .font(.title2)
                Text(book.authors)
                HStack {
                    Text(book.format)
                    Text(book.language)
                    Text(book.size)
                }
                .font(.caption)
                if book.details?.fileLinks.count ?? 0 > 0 {
                    Text("Download available")
                        .foregroundColor(.secondary)
                }
            }
        }
        .contextMenu {
            BookContext(book: book)
        }
        .task(priority: .background) {
            // try query details if there isn't.
            if book.details == nil {
                await book.loadDetails()
            }
        }
    }
    
    private var CoverView: some View {
        VStack {
            ImageView(url: book.details?.coverURL, width: 74.16, height: 120, cornerRadius: 10, defaultImg: "sailboat.fill", breathing: true)
                .frame(width: 74.16, height: 120)
        }
    }
}
