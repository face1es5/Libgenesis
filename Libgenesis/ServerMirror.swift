//
//  ServerMirror.swift
//  Libgenesis
//
//  Created by Fish on 27/8/2024.
//

import Foundation
import SwiftUI

enum ServerMirror: String, CaseIterable, Identifiable, Equatable {
    case m1 = "https://libgen.is"
    case m2 = "https://libgen.rs"
    case m3 = "https://libgen.st"
    var id: Self { self }
    
}

enum DownloadMirror: String, CaseIterable, Identifiable, Equatable {
    case libgen, cloudflare, tor, ipfs, unknown
    var id: Self { self }
    
    static func fromURL(url: URL) -> DownloadMirror {
        guard
            let suffix = url.domainSuffix(),
            let domain = url.domain()
        else {
            return .unknown
        }
        if suffix == "onion" {
            return .tor
        }
        if domain.contains("download.library.lol") {
            return .libgen
        } else if domain.contains("cloudflare-ipfs"){
            return .cloudflare
        } else if domain.contains("gateway.ipfs.io") {
            return .ipfs
        } else {
            return .unknown
        }
    }
    
    static func fromURLs(urls: [URL]) -> [DownloadMirror] {
        return urls.map{ fromURL(url: $0) }
    }
    
    static func toMenus(urls: [URL]) -> some View {
        let mirrors = fromURLs(urls: urls)
        return (
            Menu("Download from") {
                ForEach(mirrors) { mirror in
                    HStack {
                        Button(action: {
                            print("...")
                        }) {
                            Label(mirror.rawValue.lowercased(), systemImage: "eye")
                        }
                    }
                }
            }
        )
    }
    
    static func toIcon(_ url: URL) -> some View {
        return toIcon(host: fromURL(url: url))
    }
    
    static func toIcon(host: DownloadMirror) -> some View {
        switch host {
        case .tor, .libgen, .cloudflare, .ipfs:
            return Image(host.rawValue.lowercased())
        case .unknown:
            return Image(systemName: "network")
        }
    }
}

