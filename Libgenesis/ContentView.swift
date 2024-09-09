//
//  ContentView.swift
//  Libgenesis
//
//  Created by Fish on 27/8/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var selBooksVM: BooksSelectionModel
    @EnvironmentObject var booksVM: BooksViewModel
    
    var body: some View {
        NavigationSplitView {
            ScrollView {
                if let book = selBooksVM.firstBook {
                    BookDetailsView(book: book)
                } else {
                    Text("No book selected.")
                        .font(.title2)
                }
            }
            .contextMenu {
                Button("Refresh") {
                    selBooksVM.loadDetails()
                }
                if let book = selBooksVM.firstBook {
                    Divider()
                    SharedContextView(book: book)
                }
            }
            .padding()
        } detail: {
            BookListView()
                .environmentObject(booksVM)
                .environmentObject(selBooksVM)
        }
    }
    
    /// Handle a series of downloading.
    ///
    func askDownload() {
        debugPrint("Download \(selBooksVM.books.map { $0.title })")
        DownloadManager.shared.download(selBooksVM.booksArr)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
