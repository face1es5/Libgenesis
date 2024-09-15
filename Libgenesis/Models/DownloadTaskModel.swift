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
        return lhs.id == rhs.id
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
    @Published var suspending: Bool = false
    var downloadReq: DownloadRequest?
    
    var errorStr: String?
    var totalSize: Int64?
    var saveDir: String = UserDefaults.standard.string(forKey: "saveDir") ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.absoluteString
    var localURL: URL?
    
    /// Whether to user kepubify to convert epub to kepub, according to user prefercence and owned file format
    var useConverter: Bool {
        UserDefaults.standard.bool(forKey: "useKepubify") && book.format == "epub"
    }
    
    /// Choose first link except tor.
    ///
    /// Maybe support tor in future...
    init?(_ book: BookItem) {
        self.book = book
        guard
            let url = book.details?.fileLinks.first(where: { !DownloadMirror.isTor($0) })
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
        self.suspending = false
    }
    
    func setEndStatus() {
        self.loading = false
        self.suspending = false
    }
    
    /// set status when paused.
    func setPauseStatus() {
        self.loading = false
        self.suspending = true
    }
    
    /// Set status when task succeed.
    func setSuccessStatus() {
        self.loading = false
        self.suspending = false
        self.success = true
    }
    
    /// Set status when task indeed failed(not by cancelled).
    func setFailureStatus() {
        self.loading = false
        self.suspending = false
        self.success = false
    }
    
    /// Create and return download request
    ///
    private func createDownloadReq() -> DownloadRequest {
        // download
        let destination: DownloadRequest.Destination = { _, _ in
            return (self.localURL!, [.removePreviousFile, .createIntermediateDirectories])
        }
        return (
            AF.download(self.targetURL, to: destination)
                .downloadProgress(queue: .main) { progress in
                    self.progressPercent = progress.fractionCompleted.toPercentage()
    //                            print("Download progress frac: \(progress.fractionCompleted)")
                }
                .response(queue: .main) { resp in
                    if let err = resp.error {   // fail
                        self.errorStr = err.localizedDescription
                        if err.isExplicitlyCancelledError {   // cancelled
                            print("Request explicitly cancelled by user")
                        } else {    // just fail
                            print("download \(self.name) failed: \(resp.error?.localizedDescription ?? "???")")
                            self.setFailureStatus()
                        }
                    } else {    // success
                        print("download \(self.name) success.")
                        if self.useConverter {   // convert from epub to kepub
#if os(macOS)
                            print("Use converter.")
                            KepubConverter.shared.convert(src: self.localURL) { res in
                                switch res {
                                case .success(let msg):
                                    print(msg)
                                    self.setSuccessStatus()
                                    break
                                case .failure(let err):
                                    self.setFailureStatus()
                                    print("Convertion error occured: \(err)")
                                    self.errorStr = err.localizedDescription
                                    break
                                }
                            }
#endif
                        } else {
                            self.setSuccessStatus()
                        }
                    }
                }
        )
    }
    
    private func makeLocalURL() throws {
        // make&check url
        self.localURL = try DownloadTask.makeLocalURL(path: self.saveDir, filename: "\(self.book.title).\(self.book.format)")
    }
    
    /// Prepare to download, get total file size
    private func prepareToStart() {
        // get total size
        LibgenAPI.shared.fileSize(url: self.targetURL) { totalBytes in
            self.totalSize = totalBytes
        }
    }
    
    /// Suspend download task.
    func pause() {
        self.setPauseStatus()
        downloadReq?.cancel()
    }
    
    /// Just an alias for pausing
    func cancel() {
        self.pause()
    }
    
    /// Resume from suspending
    func resume() {
        /// We need to clear previous status and then, restart downloading
        /// re downloading.
        self.setStartStatus()
        // reset progress
        self.progressPercent = 0
        // if total size isn't loaded, reload
        if self.totalSize == nil {
            self.prepareToStart()
        }
        // and then, create download request, over
        self.downloadReq = createDownloadReq()
    }
    /// Start/Restart downloding
    ///
    func join() {
        clearStatus()
        setStartStatus()
        Task.detached(priority: .background) {
            do {
                // generate save location
                try await MainActor.run {
                    try self.makeLocalURL()
                }

                print("ready to download into \(self.localURL!.absoluteString)")
                self.prepareToStart()
                
                await MainActor.run {
                    self.downloadReq = self.createDownloadReq()
                }
            } catch FileError.write {
                fatalError("Handle directory wirte permission.")
                
            } catch {
                self.setFailureStatus()
                print("download \(self.name) failed: \(error)")
            }
        }
    }
    
}
