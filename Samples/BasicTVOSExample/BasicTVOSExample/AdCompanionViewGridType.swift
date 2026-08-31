//
//  AdCompanionViewGridType.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 11.03.2025.
//

import Foundation

enum AdCompanionViewGridType: CaseIterable {
    case single
    case double
    case quad
    
    var increasedGrid: AdCompanionViewGridType {
        switch self {
        case .single: .double
        case .double, .quad: .quad
        }
    }
    
    var decreasedGrid: AdCompanionViewGridType {
        switch self {
        case .single, .double: .single
        case .quad: .double
        }
    }
    
    var quantity: Int {
        switch self {
        case .single: 1
        case .double: 2
        case .quad: 4
        }
    }
}
