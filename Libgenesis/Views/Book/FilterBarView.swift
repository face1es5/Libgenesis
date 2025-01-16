//
//  FilterBarView.swift
//  Libgenesis
//
//  Created by Fish on 12/9/2024.
//

import SwiftUI

enum MatchMode: String, CaseIterable, Identifiable {
    case contains, word, start, end, re
    var id: Self { self }
    var desc: String {
        switch self {
        case .contains:
            return "Contains"
        case .word:
            return "Matches Word"
        case .start:
            return "Starts With"
        case .end:
            return "End with"
        case .re:
            return "Regex"
        }
    }
}


struct FilterBarView: View {
    @State var column: ColumnFilter = .def
    @State var filterString: String = ""
    @State var caseSensitive: Bool = false
    @State var matchMode: MatchMode = .contains
    @AppStorage("toggleFinder") var showFinder: Bool = false
    @EnvironmentObject var booksVM: BooksViewModel
    @EnvironmentObject var booksSel: BooksSelectionModel
    let proxy: ScrollViewProxy
    var filteredBooks: [BookItem] {
        booksVM.books.filter { conform($0) }
    }
    @State var anchor: Int = -1
    var book: BookItem {
        filteredBooks[anchor]
    }
    
    var body: some View {
        HStack {
            Picker(selection: $column) {
                ForEach(ColumnFilter.allCases, id: \.self) { col in
                    Text("\(col.desc)").tag(col)
                }
            } label: {}
            .frame(width: 100)
            
            TextField("Filter(press Enter to search, not press done)", text: $filterString)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    jumpNext()
                }
            Divider()
            
            Button("Aa") {
                caseSensitive.toggle()
            }
            .buttonStyle(.plain)
            .foregroundColor(caseSensitive ? .blue : .secondary)
            .help("Case sensitive")
            
            Divider()
            
            Picker(selection: $matchMode) {
                ForEach(MatchMode.allCases, id: \.self) { mode in
                    Text("\(mode.desc)")
                }
            } label: {}
            .frame(width: 120)
            
            Divider()
            HStack(spacing: 1) {
                Button(action: {
                    jumpPre()
                }) {
                    Image(systemName: "arrowtriangle.backward")
                }
                Button(action: {
                    jumpNext()
                }) {
                    Image(systemName: "arrowtriangle.forward")
                }
            }

            Button("Done") {
                showFinder.toggle()
            }
            .foregroundColor(.secondary)
        }
        .onChange(of: filterString) { _ in
            anchor = -1
        }
        .onChange(of: column) { _ in
            anchor = -1
        }
        .onChange(of: caseSensitive) { _ in
            anchor = -1
            
        }
        .onChange(of: matchMode) { _ in
            anchor = -1
        }
        .padding(.horizontal, 10)
    }
    
    func jumpNext() {
        let cnt = filteredBooks.count
        if cnt > 0, anchor < cnt-1 {
            anchor += 1
            proxy.scrollTo(book)
            booksSel.select(book)
        }
    }
    
    func jumpPre() {
        let cnt = filteredBooks.count
        if cnt > 0, anchor > 0 {
            anchor -= 1
            proxy.scrollTo(book)
            booksSel.select(book
            )
        }
    }
    
    
    /// Filter by finder
    func conform(_ book: BookItem) -> Bool {
        if filterString.count == 0{
            return true
        }
        var str: String

        var filter: String
        if matchMode == .re {
            filter = filterString
        } else {    // if not re mode, escape special chars
            filter = NSRegularExpression.escapedPattern(for: filterString)
        }

        switch column {
        case .def:
            str = book.text
            break
        case .author:
            str = book.authorLiteral
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
