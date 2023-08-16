//
//  GameMode.swift
//  TTT2
//
//  Created by Maciej on 16/08/2023.
//

import SwiftUI

enum GameMode: String, CaseIterable, Identifiable {
    case local
    case cpu
    case online
    
    var id: String {
        return self.rawValue
    }
    
    var image: Image {
        switch self {
        case .local:
            return SFSymbol.house.image
        case .cpu:
            return SFSymbol.cpu.image
        case .online:
            return SFSymbol.network.image
        }
    }
}
