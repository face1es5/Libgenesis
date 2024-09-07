//
//  MenuBar.swift
//  Libgenesis
//
//  Created by Fish on 7/9/2024.
//

import SwiftUI

struct MenuBar: View {
    @EnvironmentObject var downloadManager: DownloadManager
    
    var body: some View {
        Menu("Downloads") {
            if downloadManager.downloadTasks.count == 0 {
                Button("<No download task>") {}
            } else {
                ForEach(downloadManager.downloadTasks) { dtask in
                    Button("\(dtask.book.title)") {
                        if !dtask.loading, dtask.success {
                            LibgenesisApp.preview(dtask.localURL)
                        }
                    }
                }
            }
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
