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
    
    @Published var started: Bool = false
    
    init(_ book: BookItem) {
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
    
    func addDownloadTask(_ book: BookItem) {
        condition.lock()
        downloadTasks.append(DownloadTask(book))
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
