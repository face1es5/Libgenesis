//
//  Filter.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import Foundation
import SwiftUI

enum ColumnFilter: String, CaseIterable, Identifiable, Codable {
    case def, author, title, publisher, year, series, ISBN, language, MD5, tags
    var id: Self { self }
    
    var desc: String {
        switch self {
        case .def:  // default column, not default case.
            return "Default"
        default:
            return self.rawValue.capitalized
        }
    }
    
    var queryKey: String {
        switch self {
        case .MD5:
            return self.rawValue.lowercased()
        case .ISBN:
            return "identifier"
        default:
            return self.rawValue
        }
    }
}

enum FormatFilter: String, CaseIterable, Identifiable, Codable {
    case def, pdf, epub, mobi, txt, azw, azw3, chm, pdg, hlp, html
    
    var id: Self { self }
    
    static let allTypes = Set(Self.allCases)
    
    var desc: String {
        switch self {
        case .def:
            return "Default"
        default:
            return self.rawValue.capitalized
        }
    }
}
