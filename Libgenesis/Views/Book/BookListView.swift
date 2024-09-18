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
    @State var showBookmarks: Bool = false
    @State var formatFilters: Set<FormatFilter> = [.all]
    @AppStorage("bookLineDisplayMode") var bookDisplayMode: BookLineDisplayMode = .list
    @State var firstappear: Bool = true
    /// For finder(local filter)
    @AppStorage("toggleFinder") var showFinder: Bool = false
    /// AppStorage doesn't work in scroll view reader.
    @State var fixedShowFinder: Bool = UserDefaults.standard.bool(forKey: "toggleFinder")
    @State var extraDisplayMode: BookLineDisplayMode = BookLineDisplayMode(rawValue: UserDefaults.standard.string(forKey: "bookLineDisplayMode") ?? "list") ?? .list
    @State var isReachingEnd: Bool = false

   
    var body: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                if fixedShowFinder {
                    FilterBarView(proxy: proxy)
                        .transition(.move(edge: .top))
                        .background(
                            RoundedRectangle(cornerRadius: 0)
                                .fill(Color.gray.opacity(0.2))
                        )
                        .frame(height: 30)
                }
                ZStack(alignment: .center) {
                    List(selection: $selBooksVM.books) {
                        if extraDisplayMode == .list {
                            BookHeaderView()
                        }
                        ForEach(books, id: \.self) { book in
                            #if !os(iOS)
                            BookView(book, mode: extraDisplayMode)
                                .id(book)
                                .task {
                                    if book == books.last {
                                        fetchingNextPage()
                                    }
                                }
                            #else
                            NavigationLink(destination: BookDetailsView(book: book)) {
                                BookView(book, mode: extraDisplayMode)
                                    .id(book)
                                    .task {
                                        if book == books.last {
                                            fetchingNextPage()
                                        }
                                    }
                            }
                            #endif
                        }
                        if books.count > 0 {
                            HStack {
                                Spacer()
                                if loading, !isReachingEnd {
                                    ProgressView()
                                        .progressViewStyle(.linear)
                                } else if isReachingEnd {
                                    Text("-- No more --")
                                        .font(.title2)
                                        .foregroundColor(.primary)
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
                        ToolbarView
                    }
                    
                    if firstappear {
                        EmptyStateView

                    } else {
                        if loading {
                            ProgressView()
                        } else if books.count == 0 {
                            NoBooksView
                        }
                    }
                }
            }
            .frame(minWidth: 600)
        }
        .onChange(of: showFinder) { _ in
            withAnimation {
                fixedShowFinder.toggle()
            }
        }
        .onChange(of: bookDisplayMode) { mode in
            extraDisplayMode = mode
        }
    }
    
    private var EmptyStateView: some View {
        VStack {
            Text("Please search for some books first.")
                .font(.title)
                .foregroundColor(.secondary)
            Image("libgenLarge")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
        .padding()
    }
    
    private var NoBooksView: some View {
        VStack {
            Image("brian")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text("Oops!")
            Text("No books available, check connection or filters (maybe you're blocked by Libgen).")
        }
        .font(.title)
    }
    
    private var NavigationToolItem: some View {
        Group {
            MirrorPicker()
                .labelStyle(.titleAndIcon)
                .frame(width: 120)
            
            Picker("Display mode", selection: $bookDisplayMode) {
                ForEach(BookLineDisplayMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue.capitalized, systemImage: mode.icon).tag(mode)
                }
            }
            .pickerStyle(.inline)
            .help("Change display mode to gallery/list")
        }
    }
    
    private var PrincipleToolItem: some View {
        Group {
            Button(action: {
                showFilter.toggle()
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor((columnFilter == .def && formatFilters == [.all]) ? Color.secondary : Color.blue)
            }
            .popover(isPresented: $showFilter, arrowEdge: .bottom) {
                FilterContextView(columnFilter: $columnFilter, formatFilters: $formatFilters)
            }
            
            TextField("Search len shouldn above 3.", text: $searchString)
                .frame(width: 300, height: 100)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    forceFetching()
                }
        }
    }
    
    private var PrimaryToolItem: some View {
        Group {
            Button(action: { forceFetching() }) {
                Image(systemName: connErr ? "network" : "arrow.clockwise.circle.fill" )
                    .foregroundColor(connErr ? .yellow : .secondary)
                    .imageScale(.large)
            }
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
            .help("Click to refresh")
            
            Button(action: {
                showDownload.toggle()
            }) {
                Image(systemName: "arrow.down.circle")
                    .foregroundColor(downloadManager.downloadTasks.count == 0 ? Color.secondary : Color.blue)
                    .imageScale(.large)
                    .popover(isPresented: $showDownload, arrowEdge: .bottom) {
                        DownloadListView()
                            .frame(width: 400, height: 300)
                    }
            }
            .help("Downloads")
            
            Button(action: {
                showBookmarks.toggle()
            }) {
                HStack {
                    Label("bookmarks", systemImage: "books.vertical.fill")
//                        .foregroundColor(.blue)
                    Image(systemName: "chevron.compact.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                }
            }
            .popover(isPresented: $showBookmarks, arrowEdge: .trailing) {
                BookmarkGallery()
                    .frame(width: 400, height: 300)
            }
            .help("Bookmarks")
        }
    }
    
    /// Toolbar view
    private var ToolbarView: some View {
        Group {
#if !os(iOS)
            NavigationToolItem
#endif
            Spacer()
            PrincipleToolItem
            Spacer()
            PrimaryToolItem
        }
    }
    
    /// Handle a series of downloading.
    ///
    func askDownload() {
        print("Download \(selectedBooks.map { $0.title })")
        DownloadManager.shared.download(Array(selectedBooks))
    }
    
    /// Force fetching books from remote server, this will reset page state and deprecate previous books
    ///
    /// Do i need to reset selections? Maybe not.
    func forceFetching() {
        page = 1
        isReachingEnd = false
        Task.detached(priority: .background) {
            await fetchingBooks(force: true)
        }
    }
    
    /// Fetching books of next page.
    func fetchingNextPage() {
        if !isReachingEnd, !loading {
            page += 1
#if DEBUG
            print("Query next page: \(page).")
#endif
            Task.detached(priority: .background) {
                await fetchingBooks(page)
            }
        } else {
            print("Already reached the end or is loading.")
        }
    }
    
    /// load books of page N, if force, clear previous books
    ///
    func fetchingBooks(_ page: Int = 1, force: Bool = false) async {
        if searchString.count <= 2 {
            return
        }
        await MainActor.run {
            firstappear = false
            loading = true
        }
        #if DEBUG
        print("Page: \(page), force: \(force ? 1 : 0), loading: \(loading ? 1 : 0)")
        print("Formats: ")
        for f in formatFilters {
            print(f.rawValue)
        }
        #endif
        
        do {
            let books = try await LibgenAPI.shared.search(searchString, page: page, col: columnFilter, formats: formatFilters)
            await MainActor.run {
                isReachingEnd = books.count == 0 // if no books available, indicate there's an end.
                if force {
                    self.booksVM.books = books
                } else {
                    self.booksVM.books += books
                }
                connErr = false
            }
        } catch {
            print("Libgenesis.BookListView.fetchingBooks: \(error.localizedDescription)")
            await MainActor.run {
                connErr = true
                connErrMsg = "\(error.localizedDescription)"
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
