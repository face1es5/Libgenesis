//
//  BookDetailsToolbar.swift
//  Libgenesis
//
//  Created by Fish on 9/9/2024.
//

import SwiftUI

struct BookDetailsToolbar: View {
    @AppStorage("bookDetailsDisplayMode") var displayMode: BookDetailsDislayMode = .common
    var body: some View {
        Group {
            Picker("Display mode", selection: $displayMode) {
                ForEach(BookDetailsDislayMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.inline)
            .help("Display book info in complex/detail/simple mode.")
        }
    }
}

struct BookDetailsToolbar_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailsToolbar()
    }
}
