//
//  MenuBar.swift
//  Libgenesis
//
//  Created by Fish on 7/9/2024.
//

import SwiftUI

struct MenuBar: View {
    var body: some View {
        Menu("Downloads") {
            PlainDownloadListView()
        }
        Divider()
        Button("Settings") {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        .keyboardShortcut(",")
        Divider()
        Button("About") {
            NSApp.orderFrontStandardAboutPanel()
        }
        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

struct MenuBar_Previews: PreviewProvider {
    static var previews: some View {
        MenuBar()
    }
}
