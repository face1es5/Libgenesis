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
        #if !os(iOS)
        NavigationSplitView {
            VStack(spacing: 0) {
                BookDetailsContainer
                Spacer()
                BookDetailsBottomToolBar()
                    .frame(height: 20)
                    .padding()
            }
            .frame(minWidth: 320)
        } detail: {
            BookListView()
                .environmentObject(booksVM)
                .environmentObject(selBooksVM)
        }
        #else
        NavigationStack {
            BookListView()
                .environmentObject(booksVM)
                .environmentObject(selBooksVM)
        }
        #endif
    }
    
    var BookDetailsContainer: some View {
        ScrollView(showsIndicators: false) {
            if let book = selBooksVM.firstBook {
                BookDetailsView(book: book)
                    .padding(.trailing, 13)
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
                if let book = selBooksVM.firstBook {
                    Task.detached(priority: .background) {
                        await book.loadDetails()
                    }
                }
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
