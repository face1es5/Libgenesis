//
//  AppStorage.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import Foundation

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let res = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        self = res
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let res = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return res
    }
}

extension Set: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let res = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        self = Set(res)
    }
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let res = String(data: data, encoding: .utf8)
        else { return "[]" }
        return res
    }
}

