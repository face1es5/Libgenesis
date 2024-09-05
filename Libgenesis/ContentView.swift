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
    var body: some View {
        NavigationSplitView {
            VStack {
                if selectedBook != nil {
                    Text(selectedBook!.title)
                } else {
                    Text("No book selected.")
                }
            }
            .padding()
        } detail: {
            VStack {
                List(books, id: \.self, selection: $selectedBook) { book in
                    Text(book.title)
                }
                .listStyle(SidebarListStyle())
            }
            .toolbar {
                ToolbarItemGroup {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(.accentColor)
                            .imageScale(.large)
                            .help("Refresh")
                            .onTapGesture {
                                Task.detached(priority: .background) {
                                    await fetchingBooks()
                                }
                            }
                        Picker("mirror", selection: $mirror) {
                            ForEach(ServerMirror.allCases) { m in
                                Text(m.rawValue.lowercased())
                            }
                        }
                    }
                }
            }
            .task {
                await fetchingBooks()
            }
        }
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
