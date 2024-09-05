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
    var body: some View {
        NavigationSplitView {
            ScrollView {
                BookDetailsView(book: selectedBook)
            }
            .padding()
        } detail: {
            VStack {
                List(books, id: \.self, selection: $selectedBook) { book in
                    Text(book.title)
                        .contextMenu {
                            Button("Download \(book.truncTitle)") {
                                askDownload()
                            }
                            Button("Preview") {
                                fatalError("Preview to implemented.")
                            }
                        }
                }
                .listStyle(SidebarListStyle())
            }
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
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                        .help("Refresh")
                        .onTapGesture {
                            Task.detached(priority: .background) {
                                await fetchingBooks()
                            }
                        }
                }
            }
            .task {
                await fetchingBooks()
            }
            .searchable(text: $searchString)
        }
    }
    
    func askDownload() {
        guard let selectedBook = selectedBook else { return }
        print("Try to download: \(selectedBook.title)")
        DownloadManager.shared.addDownloadTask(selectedBook)
    }
    
    func fetchingBooks() async {
        do {
            let books = try await LibgenAPI.shared.latestBooks()
            await MainActor.run { self.books = books }
        } catch {
            print("\(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
