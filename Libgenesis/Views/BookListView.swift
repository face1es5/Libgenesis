//
//  BookListView.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import SwiftUI

struct BookListView: View {
    @EnvironmentObject var booksVM: BooksViewModel
    @EnvironmentObject var selBooksVM: BooksSelectionModel
    @EnvironmentObject var downloadManager: DownloadManager
    var books: [BookItem] {
        booksVM.books
    }
    var selectedBooks: Set<BookItem> {
        selBooksVM.books
    }
    @State var page: Int = 1
    @State var loading: Bool = true    // true if querying books
    @State var searchString: String = ""
    @State var connErr: Bool = false
    @State var connErrMsg: String = ""
    @State var showConnPopover: Bool = false
    @State var showFilter: Bool = false
    @State var columnFilter: ColumnFilter = .def
    @State var showDownload: Bool = false
    @State var showAddSheet: Bool = false
    @State var showDelAlert = false
    @AppStorage("preferredFormats") var formatFilters: Set<FormatFilter> = [.def]
    
    var body: some View {
        ZStack {
            List(selection: $selBooksVM.books) {
                ForEach(books, id: \.self) { book in
                    BookLineView(book: book)
                }
                if books.count > 0 {
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
            .contextMenu {
                Button("Refresh") {
                    forceFetching()
                }
            }
            .listStyle(.sidebar)
            .toolbar {
                toolbarView
            }
            .task {
                Task.detached(priority: .background) {
                    // On appear, force refreshing books.
                    await fetchingBooks(page, force: true)
                }
            }
            if loading {
                ProgressView()
            } else if books.count == 0 {
                VStack {
                    Image("libgenLarge")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128, height: 128)
                    Text("No books available, check connection or filters.")
                        .font(.title)
                }
            }
        }
        .navigationTitle("")
    }
    
    private var NavToolbarItem: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Menu {
                MirrorAdder(showSheet: $showAddSheet)
                MirrorDeleter(showAlert: $showDelAlert)
            } label: {
                Label("Library genesis", image: "libgen")
                    .scaledToFit()
                    .labelStyle(.iconOnly)
            }
            .sheet(isPresented: $showAddSheet) {
                MirrorSubmitSheet(showSheet: $showAddSheet)
            }
            .alert(isPresented: $showDelAlert) {
                MirrorDelAlert()
            }
            MirrorPicker()
        }
    }
    
    /// Toolbar view
    private var toolbarView: some ToolbarContent {
        Group {
            NavToolbarItem
            ToolbarItem {
                Spacer()
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    showDownload.toggle()
                }) {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(downloadManager.downloadTasks.count == 0 ? Color.secondary : Color.blue)
                        .imageScale(.large)
                        .help("Downloads")
                        .popover(isPresented: $showDownload, arrowEdge: .bottom) {
                            DownloadListView()
                        }
                }

                Button(action: { forceFetching() }) {
                    Image(systemName: "network")
                        .foregroundColor(connErr ? .yellow : .accentColor)
                        .imageScale(.large)
                }
                .help("Click to refresh")
                .keyboardShortcut("r")
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
                
                Button(action: {
                    showFilter.toggle()
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor((columnFilter == .def && formatFilters == [.def]) ? Color.secondary : Color.blue)
                }
                .popover(isPresented: $showFilter, arrowEdge: .bottom) {
                    FilterContextView(formatFilters: $formatFilters, columnFilter: $columnFilter)
                }
                SearchBar($searchString, prompt: "Search len must > 2") {
                    forceFetching()
                }
                .frame(width: 200)
            }

        }
    }
    
    /// Handle a series of downloading.
    ///
    func askDownload() {
        debugPrint("Download \(selectedBooks.map { $0.title })")
        DownloadManager.shared.download(Array(selectedBooks))
    }
    
    /// Force fetching books from remote server, this will reset page state and deprecate previous books
    ///
    /// Do i need to reset selections? Maybe not.
    func forceFetching() {
        page = 1
        Task.detached(priority: .background) {
            await fetchingBooks(force: true)
        }
    }
    
    /// load books of page N, if force, clear previous books
    ///
    func fetchingBooks(_ page: Int = 1, force: Bool = false) async {
//        if loading { return }
        await MainActor.run { loading = true }
        do {
            let books = try await LibgenAPI.shared.search(searchString, page: page, col: columnFilter, formats: formatFilters)
            await MainActor.run {
                if force {
                    self.booksVM.books = books
                } else {
                    self.booksVM.books += books
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
        await MainActor.run {
            loading = false
            // clear selections
            if force {
                selBooksVM.clear()
            }
        }
    }

}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
