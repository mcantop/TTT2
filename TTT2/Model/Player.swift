//
//  Player.swift
//  TTT2
//
//  Created by Maciej on 18/08/2023.
//

import Foundation

enum Player: Codable {
    case player1
    case player2
    case cpu
    
    var name: String {
        switch self {
        case .player1:
            return "You"
        case .player2:
            return "Player 2"
        case .cpu:
            return "CPU"
        }
    }
}
