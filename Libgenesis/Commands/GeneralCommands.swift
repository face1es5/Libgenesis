//
//  GeneralCommands.swift
//  Libgenesis
//
//  Created by Fish on 6/9/2024.
//

import SwiftUI

#if os(macOS)
struct GeneralCommands: Commands {
    var body: some Commands {
        SidebarCommands()
    }
}

struct DownloadCommands: Commands {
    @ObservedObject var downloadManager: DownloadManager
    var body: some Commands {
        CommandMenu("Download") {
            PlainDownloadListView()
                .environmentObject(downloadManager)
        }
    }
}

struct RecentFilesCommands: Commands {
    @ObservedObject var recentManager: RecentlyFilesManager
    var recentCount: Int {
        recentManager.recentlyOpened.count
    }
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Divider()
            Menu("Open Recent") {
                ForEach(recentManager.recentlyOpened.toArray(), id: \.self) { url in
                    Button("\(url.lastPathComponent)") {
                        recentManager.preview(url)
                    }
                }
                Divider()
                Button("Clear Menu") {
                    recentManager.clear()
                }
                .disabled(recentCount == 0)
            }
        }
    }
}
#endif

/// Manager for recently opened files.
class RecentlyFilesManager: ObservableObject {
    @AppStorage("recentlyOpened") var recentlyOpened = Set<URL>()
    
    /// Open preview for destination file.
    func preview(_ destination: URL?) {
        guard
            let url = destination
        else {
            print("Warning: try to open an nonexsistent file.")
            return
        }
        #if os(macOS)
        if NSWorkspace.shared.open(url) {
            recentlyOpened.insert(url)
        }
        #endif
    }
    
    /// Clear recent opened files
    func clear() {
        recentlyOpened = []
    }
}



struct GeneralCommands_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
