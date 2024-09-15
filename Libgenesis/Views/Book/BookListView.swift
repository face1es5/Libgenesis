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
    /// For finder(local filter)
    @AppStorage("togglerFinder") var showFinder: Bool = false
    @State var filterString: String = ""
    @State var colFilter_Finder: ColumnFilter = .def
    @State var matchMode: MatchMode = .contains
    @State var doFilter: Bool = true
    @State var caseSensitive: Bool = false
    var filteredBooks: [BookItem] {
        books.filter { conform($0) }
    }
    ///
    @State var showDownload: Bool = false
    @State var showAddSheet: Bool = false
    @State var showDelAlert = false
    @State var showBookmarks: Bool = false
    @AppStorage("preferredFormats") var formatFilters: Set<FormatFilter> = [.def]
    @AppStorage("bookLineDisplayMode") var bookDisplayMode: BookLineDisplayMode = .list
   
    
    var body: some View {
        VStack(spacing: 0) {
            if showFinder {
                FilterBarView(filterString: $filterString, column: $colFilter_Finder,
                              matchMode: $matchMode, caseSensitive: $caseSensitive)
                    .transition(.move(edge: .top))
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.gray.opacity(0.2))
                    )
                    .frame(height: 30)
                    .onDisappear {
                        doFilter = false
                    }
            }
            ZStack {
                List(selection: $selBooksVM.books) {
                    ForEach(filteredBooks, id: \.self) { book in
                        #if !os(iOS)
                        BookView(book, mode: bookDisplayMode)
                            .contextMenu {
                                BookContext(book: book)
                            }
                        #else
                        NavigationLink(destination: BookDetailsView(book: book)) {
                            BookView(book, mode: bookDisplayMode)
                        }
                        #endif
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
                .searchable(text: $searchString, prompt: "Search len should >= 2.")
                .onSubmit(of: .search) {
                    forceFetching()
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
                        Text("No books available, check connection or filters(maybe you're blocked by server).")
                            .font(.title)
                    }
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
                .labelStyle(.titleAndIcon)
                .frame(width: 120)
            
            Button(action: {
                showBookmarks.toggle()
            }) {
                HStack {
                    Label("bookmarks", systemImage: "books.vertical.fill")
                        .foregroundColor(.blue)
                    Image(systemName: "chevron.compact.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                }
            }
            .popover(isPresented: $showBookmarks, arrowEdge: .bottom) {
                BookmarkGallery()
                    .frame(width: 400, height: 300)
            }

        }
    }
    
    /// Toolbar view
    private var toolbarView: some ToolbarContent {
        Group {
            #if !os(iOS)
            NavToolbarItem
            ToolbarItem {
                Spacer()
            }
            #endif
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("Display mode", selection: $bookDisplayMode) {
                    ForEach(BookLineDisplayMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue.capitalized, systemImage: mode.icon).tag(mode)
                    }
                }
                .pickerStyle(.inline)
                .help("Change display mode to gallery/list")
                
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

                Button(action: { forceFetching() }) {
                    Image(systemName: "network")
                        .foregroundColor(connErr ? .yellow : .accentColor)
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
                    showFilter.toggle()
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor((columnFilter == .def && formatFilters == [.def]) ? Color.secondary : Color.blue)
                }
                .popover(isPresented: $showFilter, arrowEdge: .bottom) {
                    FilterContextView(formatFilters: $formatFilters, columnFilter: $columnFilter)
                }
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

    /// Filter by finder
    func conform(_ book: BookItem) -> Bool {
        if !doFilter || filterString.count == 0{
            return true
        }
        var str: String

        var filter: String
        if matchMode == .re {
            filter = filterString
        } else {    // if not re mode, escape special chars
            filter = NSRegularExpression.escapedPattern(for: filterString)
        }

        switch colFilter_Finder {
        case .def:
            str = book.text
            break
        case .author:
            str = book.authors
            break
        case .title:
            str = book.title
            break
        case .publisher:
            str = book.publisher
            break
        case .year:
            str = "\(book.year)"
            break
        case .series:
            str = book.series
            break
        case .ISBN:
            str = book.isbn
            break
        case .language:
            str = book.language
            break
        case .MD5:
            str = book.md5
            break
        case .tags:
            str = book.tags
            break
        }
        
        if !caseSensitive, matchMode != .re {
            str = str.lowercased()
            filter = filter.lowercased()
        }
        
        var re: String
        switch matchMode {
        case .start:
            re = "^\(filter)"
        case .end:
            re = "\(filter)$"
        case .word:
            re = "\\b\(filter)\\b"
        default:
            re = filter
        }
        guard let reg = try? Regex(re) else { return false }
        return str.contains(reg)
    }
}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
