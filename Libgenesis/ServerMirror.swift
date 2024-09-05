//
//  ServerMirror.swift
//  Libgenesis
//
//  Created by Fish on 27/8/2024.
//

import Foundation

enum ServerMirror: String, CaseIterable, Identifiable, Equatable {
    case m1 = "https://libgen.is"
    case m2 = "https://libgen.rs"
    case m3 = "https://libgen.st"
    var id: Self { self }
    
}
