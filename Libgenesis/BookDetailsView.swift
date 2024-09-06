//
//  BookDetailsView.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import SwiftUI
import Kingfisher

extension URL {
    func urlDecode() -> String {
        return self.absoluteString.urlDecode()
    }
    func domainSuffix() -> String? {
        guard
            let host = self.host(percentEncoded: true)
        else {
            return nil
        }
        return host.components(separatedBy: ".").last
    }
    func domain() -> String? {
        return self.host(percentEncoded: true)
    }
}

extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    func urlDecode() -> String {
        return self.removingPercentEncoding ?? self
    }
}

struct BookDetailsView: View {
    @Binding var book: BookItem?
    @State var detailsLoaded: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            if book != nil {
                VStack(alignment: .leading, spacing: 5) {
                    TitleView()
                        .lineLimit(2)
#if DEBUG
                    DebugView()
#endif
                    HStack {
                        CoverView()
                        InfoView()
                            .lineLimit(1)
                    }
                    DownloadsView()
                    MiscView()
                }
                AttrView()
            } else {
                Text("No book selected.")
            }
            Spacer()
        }
        .onChange(of: book) { _ in
            if book != nil, book?.details == nil {
                detailsLoaded = false
                Task.detached(priority: .background) {
                    await book?.loadDetails()
                    await MainActor.run {
                        detailsLoaded = true
                        if book?.details == nil {
                            print("Load details of book \(book?.truncTitle) failed.")
                        }
                    }
                }
            } else if book?.details == nil {
                detailsLoaded = false
            }
        }
    }
    
    private func DescriptionView() -> some View {
        return (
            DisclosureGroup {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        if detailsLoaded, book?.details != nil {    // load success
                            if (book?.details?.description.count ?? 0) > 0 {
                                Text(book?.details?.description ?? "Error occured.")
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
                        Text(book!.md5)
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("ISBN: ")
                            .bold()
                        Text(book!.isbn)
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("Edition: ")
                            .bold()
                        Text(book!.edition)
                        Spacer()
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
                if let links = book?.details?.fileLinks {
                    ForEach(links, id: \.self) { link in
                        HStack {
                            DownloadMirror.toIcon(link)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text(link.urlDecode())
                                .lineLimit(1)
                                .help(link.urlDecode())
                            Spacer()
                            Button(action: {
                                DownloadManager.shared.download(link, book: book!)
                            }) {
                                Image(systemName: "plus.app")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Click to download")
                        }
                    }
                } else {
                    Text("No available download links.")
                }
            }
            .padding()
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
                Text(book!.authors)
                    .help(book!.authors)
            }
            HStack(alignment: .top) {
                Text("Language: ")
                    .bold()
                Text(book!.language)
            }
            HStack(alignment: .top) {
                Text("Size: ")
                    .bold()
                Text("\(book!.size)")
            }
            HStack(alignment: .top) {
                Text("Format: ")
                    .bold()
                Text("\(book!.format)")
            }
        }
    }
    
    private func MiscView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .top) {
                Text("Download link pages: ")
                    .bold()
                if let mirrors = book?.mirrors {
                    ForEach(mirrors.indices, id: \.self) { idx in
                        Link(destination: mirrors[idx]) {
                            Text("[\(idx+1)]")
                        }.help(mirrors[idx].absoluteString)
                    }
                }
            }
            HStack(alignment: .top) {
                Text("Publisher: ")
                    .bold()
                Text(book!.publisher)
            }
            HStack(alignment: .top) {
                Text("Year: ")
                    .bold()
                Text("\(book!.year)")
            }
            HStack(alignment: .top) {
                Text("Pages: ")
                    .bold()
                Text("\(book!.pages)")
            }
        }
    }
    
    private func DebugView() -> some View {
        HStack {
            Text("ID: ")
                .bold()
            Text("\(book!.id)")
        }
    }
    
    private func TitleView() -> some View {
        VStack {
            if let href = book?.href {
                Link(destination: href) {
                    Text(book!.title)
                        .lineLimit(2)
                }
            } else {
                Text(book!.title)
            }
        }
        .help(book!.title)
        .font(.title2)
    }
    
    private func CoverView() -> some View {
        VStack {
            if detailsLoaded, book?.details?.coverURL != nil {
                ImageView(url: book?.details?.coverURL)
            } else {
                Image(systemName: "books.vertical")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 150)
            }
        }
    }
}

struct ImageView: View {
    let url: URL?
    var body: some View {
        KFImage(url)
            .placeholder {
                ProgressView()
                    .scaledToFit()
            }
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 150, height: 150))
                |> RoundCornerImageProcessor(cornerRadius: 20))
            .cacheOriginalImage()
            .fade(duration: 1)
            .onSuccess { result in
                print("Load image succeed: \(result.source.url?.absoluteString ?? "")")
            }
            .onFailure { error in
                print("Load image failed: \(error.localizedDescription)")
            }
            .resizable()
            .scaledToFit()
            .frame(height: 150)
    }
}

struct BookDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
