//
//  Base.swift
//  Libgenesis
//
//  Created by Fish on 7/9/2024.
//

import Foundation

extension URL {
    func urlDecode() -> String {
        return self.absoluteString.urlDecode()
    }
    func domainSuffix() -> String? {
        guard
            let host = self.host(percentEncoded: true)
        else {
            return nil
        }
        return host.components(separatedBy: ".").last
    }
    func domain() -> String? {
        return self.host(percentEncoded: true)
    }
}

extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    func urlDecode() -> String {
        return self.removingPercentEncoding ?? self
    }
    /// Assume percent is already percent num.
    static func percentage(percent: Double) -> String {
        return String(format: "%.2f %%", percent)
    }
}

extension Int64 {
    /// Format size into B/KB/MB/GB/TB.
    func sizeFormatted() -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var size = Double(self)
        var scale = 0
        while size >= 1024, scale < units.count {
            size /= 1024
            scale += 1
        }
        return String(format: "%.2f %@", size, units[scale])
    }
}

extension Double {
    func truncate(places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded(.towardZero) / factor
    }
    /// It's rounded.
    func toPercentage() -> Double {
        return self.truncate(places: 4)*100
    }
    func toPercentageStr() -> String {
        return String(format: "%.2f %%", self)
    }
    func sizeFormatted() -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var size = self
        var scale = 0
        while size >= 1024, scale < units.count {
            size /= 1024
            scale += 1
        }
        return String(format: "%.2f %@", size, units[scale])
    }
}
