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
    
    var BookDetailsContainer: some View {
        ScrollView {
            if let book = selBooksVM.firstBook {
                BookDetailsView(book: book)
            } else {
                VStack {
                    Image("stewie")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text("Hey brian.")
                        .font(.title2)
                }
            }
        }
        .contextMenu {
            Button("Refresh") {
                selBooksVM.loadDetails()
            }
            .keyboardShortcut("r")
            if let book = selBooksVM.firstBook {
                Divider()
                SharedContextView(book: book)
            }
            Divider()
            Button(action: {
                selBooksVM.clear()
            }) {
                Label("Prefer to watch cute stewie?", image: "stewie.little")
                    .labelStyle(.titleAndIcon)
            }
        }
        .toolbar {
            BookDetailsToolbar()
        }
        .padding()
    }
    
    var body: some View {
        NavigationSplitView {
            BookDetailsContainer
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
