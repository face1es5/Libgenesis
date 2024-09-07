//
//  DownloadTaskModel.swift
//  Libgenesis
//
//  Created by Fish on 6/9/2024.
//

import Foundation
import Alamofire

enum FileError: Error, LocalizedError {
    case write, read, notDirectory, notFile
    
    var localizedDescription: String? {
        switch self {
        case .write:
            return NSLocalizedString("No writing permission.", comment: "")
        case .read:
            return NSLocalizedString("No reading permission.", comment: "")
        case .notDirectory:
            return NSLocalizedString("Invalid dir path.", comment: "")
        case .notFile:
            return NSLocalizedString("Invalid file path.", comment: "")
        }
    }
}

class DownloadTask: ObservableObject, Identifiable, Hashable, Equatable {
    static func == (lhs: DownloadTask, rhs: DownloadTask) -> Bool {
        return lhs.id == rhs.id && lhs.progressPercent == rhs.progressPercent
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String = UUID().uuidString
    let book: BookItem
    var targetURL: URL
    lazy var name: String = book.truncTitle
    
    @Published var started: Bool = false
    @Published var loading: Bool = false
    @Published var success: Bool = false
    @Published var progressPercent: Double = 0
    var errorStr: String?
    var totalSize: Int64?
    var saveDir: String = UserDefaults.standard.string(forKey: "saveDir") ?? "/tmp"
    var localURL: URL?
    
    /// Choose first link except tor.
    ///
    /// Maybe support tor in future...
    init?(_ book: BookItem) {
        self.book = book
        guard
            let url = book.details?.fileLinks.first(where: { DownloadMirror.toHost(url: $0) != .tor })
        else {
            return nil
        }
        self.targetURL = url
    }
    
    init(_ url: URL, book: BookItem) {
        self.targetURL = url
        self.book = book
    }
    
    static func todayStr() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()

        // 设置日期格式：年-月-日 时:分
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        // 将当前日期转换为字符串
        let dateString = dateFormatter.string(from: currentDate)

        return dateString
    }
    
    /// make remote url into local file url, some simple checks and validate, this will change filename probably.
    static func makeLocalURL(path: String, filename: String, random: Bool = false) throws -> URL {
        let dir = URL(filePath: path)
        var fname = filename.urlDecode()    // decode
        // trunc
        if fname.count < 256 {
            fname = String(fname.prefix(256))
        }
        if !dir.hasDirectoryPath {
            throw FileError.notDirectory
        }
        // convert '/' of name into %2f
        fname = fname.replacingOccurrences(of: "/", with: "%2F")
        // check
        if fname.count == 0 || random {
            fname = "\(todayStr())-\(UUID().uuidString)"
        }

        let url = URL(filePath: fname, relativeTo: dir)
        if !url.isFileURL {
            throw FileError.notFile
        }
        
        return url
    }
    
    /// Clear status
    func clearStatus() {
        self.started = false
        self.loading = false
        self.success = false
        self.progressPercent = 0
    }
    
    /// Start download status, .e.g started = true, loading = true
    func setStartStatus() {
        self.started = true
        self.loading = true
    }
    func setEndStatus() {
        self.loading = false
    }
    
    /// Start/Restart downloding
    ///
    func join() {
        clearStatus()
        setStartStatus()
        Task.detached(priority: .background) {
            do {
                // make&check url
                self.localURL = try DownloadTask.makeLocalURL(path: self.saveDir, filename: "\(self.book.title).\(self.book.format)")
                debugPrint("ready to download into \(self.localURL!.absoluteString)")
                // get total size
                LibgenAPI.shared.fileSize(url: self.targetURL) { totalBytes in
                    self.totalSize = totalBytes
                }
                // download
                let destination: DownloadRequest.Destination = { _, _ in
                    return (self.localURL!, [.removePreviousFile, .createIntermediateDirectories])
                }
                AF.download(self.targetURL, to: destination)
                    .downloadProgress(queue: .main) { progress in
                        self.progressPercent = progress.fractionCompleted.toPercentage()
//                            print("Download progress frac: \(progress.fractionCompleted)")
                    }
                    .response(queue: .main) { resp in
                        if resp.error == nil {
                            self.success = true // set success
                            debugPrint("download \(self.name) success.")
                        } else {
                            self.errorStr = resp.error?.localizedDescription
                            debugPrint("download \(self.name) failed: \(resp.error?.localizedDescription ?? "???")")
                        }
//                        debugPrint(resp)
                        self.setEndStatus()
                    }
            } catch FileError.write {
                fatalError("Handle directory wirte permission.")
                
            } catch {
                debugPrint("download \(self.name) failed: \(error.localizedDescription)")
            }
            
            /// make status
        }
    }
}
