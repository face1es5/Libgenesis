//
//  ContentView.swift
//  Libgenesis
//
//  Created by Fish on 27/8/2024.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("baseURL") var mirror: ServerMirror = .m1
    @State var books: [BookItem] = []
    @State var selectedBook: BookItem?
    @State var showDownload: Bool = false
    @State var searchString: String = ""
    @State var connErr: Bool = false
    @State var connErrMsg: String = ""
    @State var showConnPopover: Bool = false
    @State var page: Int = 1
    @State var loading: Bool = false
    var body: some View {
        NavigationSplitView {
            ScrollView {
                BookDetailsView(book: $selectedBook)
            }
            .padding()
        } detail: {
            ZStack {
                List(selection: $selectedBook) {
                    ForEach(books, id: \.self) { book in
                        Text(book.title)
                            .contextMenu {
                                Button("Download \(book.truncTitle)") {
                                    askDownload()
                                }
                                if let links = book.details?.fileLinks {
                                    Menu("Download from") {
                                        ForEach(links, id: \.self) { link in
                                            Button(DownloadMirror.fromURL(url: link).rawValue) {
                                                DownloadManager.shared.download(link, book: book)
                                            }
                                        }
                                    }
                                }
                                Button("Preview") {
                                    fatalError("Preview to implemented.")
                                }
                            }
                    }
                    if books.count > 0, searchString.count < 2 {
                        HStack {
                            Spacer()
                            if !loading {
                                Button("More") {
                                    page += 1
                                    Task.detached(priority: .background) {
                                        await fetchingBooks(page)
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .listStyle(.sidebar)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Picker("mirror", selection: $mirror) {
                            ForEach(ServerMirror.allCases) { m in
                                Text(m.rawValue.lowercased())
                            }
                        }
                        .help("Choose mirrors.")
                    }
                    ToolbarItemGroup {
                        Image(systemName: "arrow.down.circle")
                            .imageScale(.large)
                            .help("Downloads")
                            .popover(isPresented: $showDownload, arrowEdge: .bottom) {
                                DownloadListView()
                            }
                            .onTapGesture {
                                showDownload.toggle()
                            }
                        Image(systemName: "network")
                            .foregroundColor(connErr ? .yellow : .accentColor)
                            .imageScale(.large)
                            .help("Click to refresh")
                            .onTapGesture {
                                page = 1
                                Task.detached(priority: .background) {
                                    await fetchingBooks(page, force: true)
                                }
                            }
                            .popover(isPresented: $showConnPopover) {
                                Text(connErrMsg)
                                    .lineLimit(10)
                                    .frame(width: 200)
                                    .padding()
                            }
                            .onHover { hover in
                                if connErr {
                                    showConnPopover = hover
                                } else {
                                    showConnPopover = false
                                }
                            }
                    }
                }
                .task {
                    Task.detached(priority: .background) {
                        await fetchingBooks(page)
                    }
                }
                .searchable(text: $searchString, prompt: "Search query length shoud above 2.")
                .onSubmit(of: .search) {
                    Task.detached(priority: .background) {
                        await fetchingBooks(page, force: true)
                    }
                }
                if loading {
                    ProgressView()
                }
            }

        }
    }
    
    func askDownload() {
        guard let selectedBook = selectedBook else { return }
        print("Try to download: \(selectedBook.title)")
        DownloadManager.shared.download(selectedBook)
    }
    
    /// load books of page N, if force, clear previous books
    ///
    func fetchingBooks(_ page: Int = 1, force: Bool = false) async {
        if loading { return }
        await MainActor.run { loading = true }
        do {
            let books = try await LibgenAPI.shared.search(searchString, page: page)
            await MainActor.run {
                if force {
                    self.books = books
                } else {
                    self.books += books
                }
                connErr = false
            }
        } catch {
            print("error occured: \(error)")
            await MainActor.run {
                connErr = true
                connErrMsg = "\(error)"
            }
        }
        await MainActor.run { loading = false }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
