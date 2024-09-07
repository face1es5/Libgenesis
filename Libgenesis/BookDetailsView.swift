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
                TitleView()
                    .lineLimit(2)
#if DEBUG
                DebugView()
#endif
                HStack {
                    CoverView()
                    InfoView()
                        .lineLimit(2)
                }
                DownloadsView()
                MiscView()
            }
            AttrView()
            Spacer()
        }
        .task {
            if book.details == nil {
                loadDetails(self.book)
            }
        }
        .onChange(of: book) { newbook in
            debugPrint("\(newbook.id) md5: \(newbook.md5)")
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
    
    private func DescriptionView() -> some View {
        return (
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
        )
    }
    
    private func AttrView() -> some View {
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
            DescriptionView()
        }
    }
    
    private func DownloadsView() -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 20) {
                if let links = book.details?.fileLinks {
                    ForEach(links, id: \.self) { link in
                        HStack {
                            DownloadMirror.toIcon(link)
                                .frame(width: 20, height: 20)
                                .scaledToFit()
                            Text(link.urlDecode())
                                .lineLimit(1)
                            Spacer()
                        }
                        .onTapGesture {
                            DownloadManager.shared.download(link, book: book)
                        }
                        .hoveringEffect(0.5, duration: 1)
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
    
    private func InfoView() -> some View {
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
    
    private func MiscView() -> some View {
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
    
    private func DebugView() -> some View {
        HStack {
            Text("ID: ")
                .bold()
            Text("\(book.id)")
        }
    }
    
    private func TitleView() -> some View {
        VStack {
            if let href = book.href {
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
    
    private func CoverView() -> some View {
        VStack {
            ImageView(url: book.details?.coverURL, width: 100, height: 161.8, cornerRadius: 10, defaultImg: "books.vertical")
                .frame(width: 100, height: 161.8)
        }
    }
}

struct ImageView: View {
    let url: URL?
    var preferredWidth: CGFloat = 150
    var preferredHeight: CGFloat = 150
    var cornerRadius: CGFloat = 20
    var defaultImg: String
    var breathing: Bool = false
    
    init(url: URL?, defaultImg: String = "eye", breathing: Bool = false) {
        self.url = url
        self.defaultImg = defaultImg
        self.breathing = false
    }
    
    init(url: URL?, width: CGFloat = 150, height: CGFloat = 150, cornerRadius: CGFloat = 20, defaultImg: String = "eye", breathing: Bool = false) {
        self.url = url
        self.preferredWidth = width
        self.preferredHeight = height
        self.cornerRadius = cornerRadius
        self.defaultImg = defaultImg
        self.breathing = breathing
    }
    
    var body: some View {
        if let url = self.url {
            KFImage(url)
                .placeholder {
                    ProgressView()
                        .scaledToFit()
                }
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: preferredWidth, height: preferredHeight))
                              |> RoundCornerImageProcessor(cornerRadius: cornerRadius))
                .cacheMemoryOnly()
                .retry(maxCount: 3, interval: .seconds(5))
                .fade(duration: 1)
                .onSuccess { result in
//                    print("Load image succeed: \(result.source.url?.absoluteString ?? "")")
                }
                .onFailure { error in
                    print("Load image failed: \(error.localizedDescription)")
                }
                .resizable()
                .scaledToFit()
//                .background(Color.clear)
//                .overlay(
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .stroke(.clear, lineWidth: 1)
//                )
        } else {
            if breathing {
                Image(systemName: defaultImg)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: preferredWidth, maxHeight: preferredHeight)
                    .breathingEffect()
                    .cornerRadius(cornerRadius)
            } else {
                Image(systemName: defaultImg)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: preferredWidth, maxHeight: preferredHeight)
                    .cornerRadius(cornerRadius)
            }
        }

    }
    
}

struct BookDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
