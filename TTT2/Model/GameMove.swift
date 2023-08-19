//
//  GameMove.swift
//  TTT2
//
//  Created by Maciej on 18/08/2023.
//

import Foundation

struct GameMove: Codable, Equatable {
    let player: Player
    let position: Int
    
    var type: String {
        return player == .player1 ? "xmark" : "circle"
    }
}
