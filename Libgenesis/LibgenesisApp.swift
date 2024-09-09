//
//  LibgenesisApp.swift
//  Libgenesis
//
//  Created by Fish on 27/8/2024.
//

import SwiftUI
import Kingfisher

@main
struct LibgenesisApp: App {
    @StateObject var downloadManager: DownloadManager = DownloadManager.shared
    @AppStorage("theme") var theme: Theme = .system
    @StateObject var selBooksVM: BooksSelectionModel = BooksSelectionModel()
    @StateObject var booksVM: BooksViewModel = BooksViewModel()
    @StateObject var recentManager: RecentlyFilesManager = RecentlyFilesManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(downloadManager)
                .preferredColorScheme(colorScheme())
                .onAppear {
                    #if os(iOS) // in ios, watching
                    NotificationCenter.default.addObserver(forName: NSApplication.didReceiveMemoryWarningNotification,
                                                           object: nil,
                                                           queue: .main) { _ in
                        clearImageCache()
                    }
                    #endif
                }
                .environmentObject(selBooksVM)
                .environmentObject(booksVM)
                .environmentObject(downloadManager)
                .environmentObject(recentManager)
        }
        Window("Downloader", id: "downloader-window") {
            DownloaderView()
        }
        #if !os(watchOS)
        .commands {
            GeneralCommands()
            DownloadCommands(downloadManager: downloadManager)
            RecentFilesCommands(recentManager: recentManager)
        }
        #endif
        #if os(macOS)
        MenuBarExtra(content: {
            MenuBar()
                .environmentObject(downloadManager)
        }, label: {
            HStack {
                Image("libgen")
                if downloadManager.downloadTasks.count > 0 {
                   Text(" \(downloadManager.downloadTasks.count)")
                }
            }
        })
        Settings {
            SettingsView()
                .preferredColorScheme(colorScheme())
        }
        #endif

    }
    private func colorScheme() -> ColorScheme? {
        switch theme {
        case .system:
            return .none
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    /// Clear image cache.
    static func clearImageCache() {
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
    /// Jump to directory, or parent dir of it.
    static func jumpTo(_ destination: URL?) {
        guard
            let url = destination
        else {
            print("Warning: try jump to nil URL.")
            return
        }
        NSWorkspace.shared.open(url.deletingLastPathComponent())
    }
   
}
