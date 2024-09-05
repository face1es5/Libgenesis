//
//  BookDetailsView.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import SwiftUI

struct Field: View {
    let key: String,
        value: String
    var body: some View {
        Text(NSLocalizedString(key, comment: "") + ": " + value)
            .multilineTextAlignment(.leading)
    }
}

extension Form {
    func field(key: String, value: String) -> some View {
        self.overlay(Field(key: key, value: value))
    }
}

struct BookDetailsView: View {
    let book: BookItem?
    var body: some View {
        VStack {
            if book != nil {
                VStack(alignment: .leading, spacing: 5) {
                    Text(book!.title)
                        .font(.title2)
                        .help(book!.title)
                    HStack(alignment: .top) {
                        Text("Author(s): ")
                            .bold()
                        Text(book!.authors)
                            .help(book!.authors)
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("Publisher: ")
                            .bold()
                        Text(book!.publisher)
                    }
                    HStack(alignment: .top) {
                        Text("Year: ")
                            .bold()
                        Text("\(book!.year)")
                    }
                    HStack(alignment: .top) {
                        Text("Pages: ")
                            .bold()
                        Text("\(book!.pages)")
                    }
                    HStack(alignment: .top) {
                        Text("Language: ")
                            .bold()
                        Text(book!.language)
                    }
                    HStack(alignment: .top) {
                        Text("Size: ")
                            .bold()
                        Text("\(book!.size)")
                    }
                    HStack(alignment: .top) {
                        Text("Format: ")
                            .bold()
                        Text("\(book!.format)")
                    }
                    DisclosureGroup {
                        HStack(alignment: .top) {
                            Text("Md5: ")
                                .bold()
                            Text(book!.md5)
                            Spacer()
                        }
                        HStack(alignment: .top) {
                            Text("ISBN: ")
                                .bold()
                            Text(book!.isbn)
                            Spacer()
                        }
                        HStack(alignment: .top) {
                            Text("Edition: ")
                                .bold()
                            Text(book!.edition)
                            Spacer()
                        }
                    } label: {
                        Text("More")
                            .bold()
                    }
                    .frame(alignment: .leading)
                }
                .lineLimit(3)
            } else {
                Text("No book selected.")
            }
            Spacer()
        }
    }
}

struct BookDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailsView(book: nil)
    }
}
