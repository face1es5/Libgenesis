//
//  Downloader.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import Foundation

class DownloadTask: ObservableObject, Identifiable {
    let id = UUID().uuidString
    let book: BookItem
    var targetURL: URL?
    
    @Published var started: Bool = false
    
    init(_ book: BookItem) {
        self.book = book
        self.targetURL = book.details?.fileLinks.randomElement()
    }
    
    init(_ url: URL, book: BookItem) {
        self.targetURL = url
        self.book = book
    }
}

/// Book downloader, hold download queue
class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var downloadTasks: [DownloadTask] = []
    private let downloadTaskQueue = DispatchQueue(label: "com.F1sh.downloadmanager.taskqueue", qos: .background)
    private let condition = NSCondition()
    
    private init() {
        starting()
    }
    
    func download(_ from: URL, book: BookItem) {
        downloadTasks.append(DownloadTask(from, book: book))
    }
    
    func download(_ book: BookItem) {
        downloadTasks.append(DownloadTask(book))
    }
    
    func addDownloadTask(_ dtask: DownloadTask) {
        condition.lock()
        downloadTasks.append(dtask)
        condition.unlock()
        condition.signal()
    }
    
    private func starting() {
        downloadTaskQueue.async { [weak self] in
            guard let self = self else { return }
            while(true) {
                // aquire lock and waiting for new downloading task.
                while(downloadTasks.isEmpty) {
                    condition.lock()
                    condition.wait()
                }
                guard
                    let task = downloadTasks.first(where: { $0.started == false })
                else {
                    condition.unlock()
                    continue
                }
                task.started = true
                //TODO: real download...
                print("Starting download: \(task.book.title)")
                condition.unlock()
            }
        }
    }
}
