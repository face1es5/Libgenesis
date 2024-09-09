//
//  BookDetailsView.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import SwiftUI
import Kingfisher



struct BookDetailsView: View {
    @ObservedObject var book: BookItem
    @State var detailsLoaded: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {
                TitleView
                    .lineLimit(2)
#if DEBUG
                DebugView
#endif
                HStack {
                    CoverView
                    InfoView
                        .lineLimit(2)
                }
                DownloadsView
                MiscView
            }
            AttrView
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
                if book.details == nil {
                    debugPrint("Load details of book \(String(describing: book.truncTitle)) failed.")
                } else {
                    debugPrint("Load details of book \(String(describing: book.truncTitle)) succeed.")
                }
            }
        }
    }
    
    private var DescriptionView: some View {
        Group {
            DisclosureGroup {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        if detailsLoaded, book.details != nil {    // load success
                            if (book.details?.description.count ?? 0) > 0 {
                                Text(book.details?.description ?? "Failed to load description.")
                                    .lineLimit(15)
                            }
                        } else if !detailsLoaded {  // loading...
                            ProgressView()
                                .frame(width: 20, height: 20)
                                .aspectRatio(contentMode: .fit)
                        } else {    // loading failed.
                            Text("None.")
                        }
                        Spacer()
                    }
                }
                .padding()
            } label: {
                Label("Description", systemImage: "books.vertical")
                    .bold()
            }
        }
    }
    
    private var AttrView: some View {
        VStack(alignment: .leading, spacing: 5) {
            DisclosureGroup {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("Md5: ")
                            .bold()
                        Spacer()
                        Text(book.md5)
                    }
                    HStack(alignment: .top) {
                        Text("ISBN: ")
                            .bold()
                        Spacer()
                        Text(book.isbn)
                    }
                    HStack(alignment: .top) {
                        Text("Edition: ")
                            .bold()
                        Spacer()
                        Text(book.edition)
                    }
                }
                .padding()
            } label: {
                Text("More")
                    .bold()
            }
            DescriptionView
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
                Spacer()
                Text(book.authors)
                    .help(book.authors)
            }
            HStack(alignment: .top) {
                Text("Language: ")
                    .bold()
                Spacer()
                Text(book.language)
            }
            HStack(alignment: .top) {
                Text("Size: ")
                    .bold()
                Spacer()
                Text("\(book.size)")
            }
            HStack(alignment: .top) {
                Text("Format: ")
                    .bold()
                Spacer()
                Text("\(book.format)")
            }
        }
    }
    
    private var MiscView: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .top) {
                Text("Download link pages: ")
                    .bold()
                ForEach(book.mirrors.indices, id: \.self) { idx in
                    Link(destination: book.mirrors[idx]) {
                        Text("[\(idx+1)]")
                    }.help(book.mirrors[idx].absoluteString)
                }
            }
            HStack(alignment: .top) {
                Text("Publisher: ")
                    .bold()
                Text(book.publisher)
            }
            HStack(alignment: .top) {
                Text("Year: ")
                    .bold()
                Text("\(book.year)")
            }
            HStack(alignment: .top) {
                Text("Pages: ")
                    .bold()
                Text("\(book.pages)")
            }
        }
    }
    
    private var DebugView: some View {
        HStack {
            Text("ID: ")
                .bold()
            Text("\(book.id)")
        }
    }
    
    private var TitleView: some View {
        VStack {
            if let dhref = book.detailHerf {
                Link(destination: dhref) {
                    Text(book.title)
                        .lineLimit(2)
                }
            } else if let href = book.href {
                Link(destination: href) {
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
    
    private var CoverView: some View {
        VStack {
            ImageView(url: book.details?.coverURL, width: 100, height: 161.8, cornerRadius: 10, defaultImg: "books.vertical", breathing: true)
                .frame(width: 100, height: 161.8)
        }
    }
}



struct BookDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
