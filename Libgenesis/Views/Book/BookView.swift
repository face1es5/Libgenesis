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

enum ColumnField: String, CaseIterable, Identifiable, Codable {
    case author, year, publisher, language, isbn, format, pages, ID
    var id: Self { self }
    
    var description: String {
        switch self {
        case .author:
            return "Author(s)"
        default:
            return self.rawValue.capitalized
        }
    }
}

/// Table header
struct BookHeaderView: View {
    let largeColWidth: CGFloat = 200
    let colWidth: CGFloat = 100
    let smallColWidth: CGFloat = 50
    
    @AppStorage("columnFields") var cols: Set<ColumnField> = Set(ColumnField.allCases)
    
    func Column(_ str: String, width: CGFloat) -> some View {
        return (
            Group {
                Text(str)
                    .leftAlign(width: width)
                Divider()
            }
        )

    }
    
    var body: some View {
        HStack {
            Column("Title", width: largeColWidth)
            if cols.contains(.author) {
                Column("Author(s)", width: colWidth)
            }
            if cols.contains(.year) {
                Column("Year", width: smallColWidth)
            }
            if cols.contains(.publisher) {
                Column("Publisher", width: colWidth)
            }
            if cols.contains(.language) {
                Column("Language", width: colWidth)
            }
            if cols.contains(.isbn) {
                Column("ISBN", width: colWidth)
            }
            if cols.contains(.format) {
                Column("Format", width: smallColWidth)
            }
            if cols.contains(.pages) {
                Column("Pages", width: smallColWidth)
            }
            if cols.contains(.ID) {
                Column("ID", width: smallColWidth)
            }
        }
        .lineLimit(1)
        .contextMenu {
            ColumnSelector
        }
    }
    
    var ColumnSelector: some View {
        ForEach(ColumnField.allCases, id: \.self) { col in
            Button("\(cols.contains(col) ? "✓ " : "    ")\(col.description)") {
                if cols.contains(col) {
                    cols.remove(col)
                } else {
                    cols.insert(col)
                }
            }
        }
    }
}

/// Table row
struct BookRowView: View {
    @ObservedObject var book: BookItem
    let largeColWidth: CGFloat = 200
    let colWidth: CGFloat = 100
    let smallColWidth: CGFloat = 50
    @AppStorage("columnFields") var cols: Set<ColumnField> = Set(ColumnField.allCases)
    
    func Column(_ str: String, width: CGFloat) -> some View {
        return (
            Group {
                Text(str)
                    .leftAlign(width: width)
                    .help(str)
                Divider()
            }
        )
    }
    
    /// Handle download targe book.
    private func askDownload(_ book: BookItem) async {
        if book.details == nil {
            await book.loadDetails()
        }
        DownloadManager.shared.download(book)
    }
    
    @State var fuck: Int = 1
    
    var body: some View {
        HStack {
            Column(book.title, width: largeColWidth)
            if cols.contains(.author) {
                Column(book.authorLiteral, width: colWidth)
            }
            if cols.contains(.year) {
                Column("\(book.year)", width: smallColWidth)
            }
            if cols.contains(.publisher) {
                Column(book.publisher, width: colWidth)
            }
            if cols.contains(.language) {
                Column(book.language, width: colWidth)
            }
            if cols.contains(.isbn) {
                Column(book.isbn, width: colWidth)
            }
            if cols.contains(.format) {
                Column(book.format, width: smallColWidth)
            }
            if cols.contains(.pages) {
                Column("\(book.pages)", width: smallColWidth)
            }
            if cols.contains(.ID) {
                Column(book.id, width: smallColWidth)
            }
        }
        .lineLimit(1)
    }
}

/// Book with cover
struct BookCoverView: View {
    @ObservedObject var book: BookItem
    @Environment(\.colorScheme) var scheme: ColorScheme
    var body: some View {
        HStack(spacing: 20) {
            CoverView
            VStack(alignment: .leading, spacing: 5) {
                Text(book.title)
                    .textSelectable(scheme)
                    .font(.title2)
                Text(book.authorLiteral)
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
    }
    
    private var CoverView: some View {
        VStack {
            ImageView(url: book.coverURL, width: 74.16, height: 120, cornerRadius: 10, defaultImg: "sailboat.fill", breathing: true)
                .frame(width: 74.16, height: 120)
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
            BookMarkMenuView(book: book)
        }
    }
}


struct BookView: View {
    @ObservedObject var book: BookItem
    @State var showPreview: Bool = false
    let mode: BookLineDisplayMode
    init(_ book: BookItem, mode: BookLineDisplayMode) {
        self.book = book
        self.mode = mode
    }
    
    var body: some View {
        if mode == .list {
            BookRowView(book: book)
                .contextMenu {
                    BookContext(book: book)
                }
        } else if mode == .gallery {
            BookCoverView(book: book)
                .contextMenu {
                    BookContext(book: book)
                }
        }
    }
}


