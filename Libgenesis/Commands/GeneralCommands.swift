//
//  GeneralCommands.swift
//  Libgenesis
//
//  Created by Fish on 6/9/2024.
//

import SwiftUI

struct GeneralCommands: Commands {
    var body: some Commands {
        SidebarCommands()
    }
}

struct DownloadCommands: Commands {
    @ObservedObject var downloadManager: DownloadManager
    var body: some Commands {
        CommandMenu("Download") {
            if downloadManager.downloadTasks.count == 0 {
                Button("<No download task>") {
                }
                .disabled(true)
            } else {
                VStack {
                    ForEach(downloadManager.downloadTasks, id: \.self) { dtask in
                        Button(dtask.book.title) {
                            if !dtask.loading, dtask.success {
                                LibgenesisApp.preview(dtask.localURL)
                            }
                        }
                    }
                    Divider()
                    Button("Clear") {
                        fatalError("Implement clear download menu")
                    }
                }
            }
        }
    }
}

//struct WindowCommands: Commands {
//    @Environment(\.openWindow) private var openDownloader
//    var body: some Commands {
//        CommandGroup(after: .windowArrangement) {
//            Button("Open download window") {
//                openDownloader(id: "downloader-window")
//            }
//        }
//    }
//}


struct GeneralCommands_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
