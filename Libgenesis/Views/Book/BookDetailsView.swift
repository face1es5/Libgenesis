//
//  BookDetailsView.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import SwiftUI
import Kingfisher



struct BookDetailsView: View {
    @AppStorage("bookDetailsDisplayMode") var displayMode: BookDetailsDislayMode = .complex
    @ObservedObject var book: BookItem
    @Environment(\.colorScheme) var scheme
    @State var detailsLoaded: Bool = false
    let fixedKeyWidth: CGFloat = 80
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TitleView
#if DEBUG
            DebugView
#endif
            if displayMode == .complex {
                HStack {
                    CoverView()
                    InfoView
                        .lineLimit(1)
                }
            } else {
                HStack {
                    Spacer()
                    CoverView(width: 123.6, height: 200, radius: 15)
                    Spacer()
                }
                InfoView
            }
            MiscView
                .lineLimit(1)
            if displayMode != .simple {
                AttrView
                    .lineLimit(1)
            }
            if displayMode != .simple {
                DownloadsView
            }
            DescriptionView
            Spacer()
        }
        .task {
            if book.details == nil {
                loadDetails(self.book)
            }
        }
        .onChange(of: book) { newbook in
            if newbook.details == nil {
                print("Detect book changes and new book's details is nil, load details.")
                loadDetails(newbook)
            }
        }
    }
    
    private func loadDetails(_ book: BookItem) {
        detailsLoaded = false
        Task.detached(priority: .background) {
            await book.loadDetails()
            await MainActor.run {
                detailsLoaded = true
            }
        }
    }
    
    private var DescriptionView: some View {
        Group {
            DisclosureGroup {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        if detailsLoaded, let details = book.details {    // load success
                            SelectableText(details.description)
                                .lineLimit(.max)
                        } else if !detailsLoaded {  // loading...
                            Text("Loading description...")
                        } else {    // loading failed.
                            Text("N/A")
                        }
                        Spacer()
                    }
                }
                .padding()
            } label: {
                HStack {
                    Label("Description", systemImage: "books.vertical")
                        .bold()
                    if !detailsLoaded, book.details == nil {
                        ProgressView()
                            .frame(width: 15, height: 15)
                            .scaledToFit()
                            .scaleEffect(x: 0.5, y: 0.5)
                    }
                }
            }
        }
    }
    
    private var AttrView: some View {
        VStack(alignment: .leading, spacing: 5) {
            DisclosureGroup {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("Md5: ")
                            .leftAlign(width: fixedKeyWidth)
                            .bold()
                        SelectableText(book.md5)
                            .help(book.md5)
                    }
                    HStack(alignment: .top) {
                        Text("ISBN: ")
                            .leftAlign(width: fixedKeyWidth)
                            .bold()
                        SelectableText(book.isbn)
                            .help(book.isbn)
                    }
                    HStack(alignment: .top) {
                        Text("Edition: ")
                            .leftAlign(width: fixedKeyWidth)
                            .bold()
                        SelectableText(book.edition)
                            .help("Edition of this book")
                    }
                }
                .padding()
            } label: {
                Label("More information", systemImage: "info.bubble.fill")
                    .bold()
            }
        }
        
    }
    
    private var DownloadsView: some View {
        Group {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 20) {
                    if let links = book.details?.fileLinks {
                        ForEach(links, id: \.self) { link in
                            HStack {
                                DownloadMirror(link).toImage()
                                    .frame(width: 20, height: 20)
                                    .scaledToFit()
                                Text(link.urlDecode())
                                    .lineLimit(1)
                                Spacer()
                            }
                            .onTapGesture {
                                DownloadManager.shared.download(link, book: book)
                            }
                            .hoveringEffect(0.5, duration: 1, radius: 5)
                            .contextMenu {
                                Button("Download \(book.truncTitle) from this mirror") {
                                    DownloadManager.shared.download(link, book: book)
                                }
                            }
                            .help("Click to download this book")
                        }
                    } else {
                        Text("No available download links.")
                    }
                }
                .padding(5)
            } label: {
                Label("Downloads", systemImage: "square.and.arrow.down.on.square.fill")
                    .bold()
            }
        }
    }
    
    private var InfoView: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .top) {
                Text("Author(s): ")
                    .bold()
                    .leftAlign(width: fixedKeyWidth)
                SelectableText(book.authors)
                    .help(book.authors)
            }
            HStack(alignment: .top) {
                Text("Language: ")
                    .bold()
                    .leftAlign(width: fixedKeyWidth)
                SelectableText(book.language)
            }
            HStack(alignment: .top) {
                Text("Size: ")
                    .bold()
                    .leftAlign(width: fixedKeyWidth)
                SelectableText("\(book.size)")
            }
            HStack(alignment: .top) {
                Text("Format: ")
                    .bold()
                    .leftAlign(width: fixedKeyWidth)
                SelectableText("\(book.format)")
            }
        }
        .padding(.leading, 13)
    }
    
    private var MiscView: some View {
        VStack(alignment: .leading, spacing: 5) {
            if displayMode == .complex {
                HStack(alignment: .top) {
                    Text("Download link pages: ")
                        .bold()
                    ForEach(book.mirrors.indices, id: \.self) { idx in
                        Link(destination: book.mirrors[idx]) {
                            Text("[\(idx+1)]")
                        }.help(book.mirrors[idx].absoluteString)
                    }
                }
            }

            HStack(alignment: .top) {
                Text("Publisher: ")
                    .bold()
                    .leftAlign(width: fixedKeyWidth)
                SelectableText(book.publisher)
            }
            HStack(alignment: .top) {
                Text("Year: ")
                    .bold()
                    .leftAlign(width: fixedKeyWidth)
                Text("\(book.year)")
            }
            HStack(alignment: .top) {
                Text("Pages: ")
                    .bold()
                    .leftAlign(width: fixedKeyWidth)
                Text("\(book.pages)")
            }
        }
        .padding(.leading, 13)
    }
    
    private var DebugView: some View {
        HStack {
            Text("ID: ")
                .bold()
            Text("\(book.id)")
                .leftAlign(width: fixedKeyWidth)
        }
    }
    
    private var TitleView: some View {
        VStack {
            if let dhref = book.detailURL {
                Link(destination: dhref) {
                    Text(book.title)
                        .lineLimit(1)
                }
            } else if let href = book.searchURL {
                Link(destination: href) {
                    Text(book.title)
                        .lineLimit(1)
                }
            } else {
                SelectableText(book.title)
                    .lineLimit(1)
            }
        }
        .help(book.title)
        .font(.title2)
    }
    
    private func CoverView(width: CGFloat = 100, height: CGFloat = 161.8, radius: CGFloat = 10) -> some View {
        VStack {
            ImageView(url: book.details?.coverURL, width: width, height: height, cornerRadius: radius, defaultImg: "books.vertical", breathing: true)
                .frame(width: width, height: height)
        }
    }

    private func SelectableText(_ text: String) -> some View {
        return (
            Text(text)
                .textSelection(.enabled)
                .foregroundColor(scheme == .light ? .black : .white)
        )
    }
}



struct BookDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
