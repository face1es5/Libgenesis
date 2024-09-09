//
//  BookDetailsDisplayMode.swift
//  Libgenesis
//
//  Created by Fish on 9/9/2024.
//

import SwiftUI

enum BookDetailsDislayMode: String, CaseIterable, Identifiable {
    case complex, common, simple
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .common:
            return "list.bullet"
        case .simple:
            return "dot.viewfinder"
        case .complex:
            return "eyeglasses"
        }

    }
}

enum BookLineDisplayMode: String, CaseIterable, Identifiable {
    case gallery, list
    var id: Self { self }
    var icon: String {
        switch self {
        case .gallery:
            return "photo.artframe"
        case .list:
            return "list.bullet"
        }
    }
}

