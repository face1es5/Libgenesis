//
//  APIService.swift
//  Libgenesis
//
//  Created by Fish on 27/8/2024.
//

import Foundation
import Alamofire

class APIService {
    var urlstr: String
    init(to: String) {
        urlstr = to
    }
    init(to: URL) {
        urlstr = to.absoluteString
    }
    func getHtml() async throws -> String {
        guard let url = URL(string: urlstr) else { throw APIError.invalidURL }
        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            guard
                let resp = resp as? HTTPURLResponse,
                (200 ... 299) ~= resp.statusCode
            else {
                throw APIError.invalidResponse
            }
            guard let res = String(data: data, encoding: .utf8)
            else {
                throw APIError.decodingError
            }
            return res
        } catch {
            throw error
        }
    }
    
    /// Use URLSession api to download api, **NOT IMPLEMENTED YET.** maybe don't need to...
    func load(_ local: URL?) async throws {
        fatalError("Implement original download api.")
    }
    
    func downloadTo(_ local: URL) throws {
        let destination: DownloadRequest.Destination = { _, _ in
            return (local, [.removePreviousFile, .createIntermediateDirectories])
        }
        guard let url = URL(string: urlstr) else { throw APIError.invalidURL }
        AF.download(url, to: destination)
            .downloadProgress { progress in
                print("Download progress: \(progress.fractionCompleted)")
            }
            .response { resp in
                debugPrint(resp)
            }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case nilURL
    
}
