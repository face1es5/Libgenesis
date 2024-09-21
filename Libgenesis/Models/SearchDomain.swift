//
//  SearchDomain.swift
//  Libgenesis
//
//  Created by Fish on 21/9/2024.
//

import Foundation

enum SearchDomain: String, CaseIterable, Identifiable {
    case def, fiction, sci
    var id: Self { self }
    var desc: String {
        switch self {
        case .def:
            return "Default"
        case .fiction:
            return "Fiction"
        case .sci:
            return "SCI"
        }
    }
}
