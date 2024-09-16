//
//  ServerMirror.swift
//  Libgenesis
//
//  Created by Fish on 27/8/2024.
//

import Foundation
import SwiftUI

struct ServerMirror: Identifiable, Codable, Hashable, CustomStringConvertible {
    let url: URL
    var domain: String {
        url.domain() ?? "Invalid url: \(url.absoluteString)"
    }
    var description: String {
        domain
    }
    
    init?(_ urlstr: String) {
        guard let url = URL(string: urlstr),
              let _ = url.domain()
        else { return nil }
        self.url = url
    }
    
    var id: URL { self.url }
    
    static var defaults: [ServerMirror] {
        DefaultServerMirror.toServerMirrors()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    static let defaultMirror = defaults[0]
    
    enum DefaultServerMirror: String, CaseIterable, Identifiable, Equatable {
        case m1 = "https://libgen.is"
        case m2 = "https://libgen.rs"
        case m3 = "https://libgen.st"
        var id: Self { self }
        
        var desc: String {
            URL(string: self.rawValue)!.domain()!
        }
        
        static func toServerMirrors() -> [ServerMirror] {
            return self.allCases.compactMap { ServerMirror($0.rawValue) }
        }
    }
}

class ObservableMirror: ObservableObject, Identifiable, Hashable {
    static func == (lhs: ObservableMirror, rhs: ObservableMirror) -> Bool {
        lhs.url == rhs.url
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    

    let url: URL
    var id: URL { self.url }
    var domain: String {
        url.domain() ?? "Invalid url: \(url.absoluteString)"
    }
    var description: String {
        domain
    }
    @Published var stat: Bool = true
    
    init(_ mirror: ServerMirror) {
        self.url = mirror.url
    }
    init?(_ urlstr: String) {
        guard let url = URL(string: urlstr),
              let _ = url.domain()
        else { return nil }
        self.url = url
    }
}

enum DownloadMirror: String, CaseIterable, Identifiable, Equatable {
    case libgen, cloudflare, tor, ipfs, unknown, pinata
    var id: Self { self }
    
    init(_ url: URL) {
        guard
            let suffix = url.domainSuffix(),
            let domain = url.domain()
        else {
            self = .unknown
            return
        }
        if suffix == "onion" || domain.starts(with: ".*libgenfrialc") {
            self = .tor
        } else if domain.contains("download.library.lol") {
            self = .libgen
        } else if domain.contains("cloudflare-ipfs"){
            self = .cloudflare
        } else if domain.contains("gateway.ipfs.io") {
            self =  .ipfs
        } else if domain.contains("pinata") {
            self = .pinata
        } else {
            self = .unknown
        }
    }
    
    static func isTor(_ url: URL) -> Bool {
        guard
            let suffix = url.domainSuffix(),
            let domain = url.domain()
        else {
            return false
        }
        return suffix == "onion" || domain.starts(with: ".*libgenfrialc")
    }
    
    var serverName: String {
        switch self {
        case .libgen:
            return "Library genesis"
        default:
            return self.rawValue.capitalized
        }
    }
    
    func toImage() -> some View {
        switch self {
        case .unknown:
            return Image(systemName: "network")
        default:
            return Image(self.rawValue.lowercased())
        }
    }
}



