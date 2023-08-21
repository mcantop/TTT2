//
//  GameOnline.swift
//  TTT2
//
//  Created by Maciej on 20/08/2023.
//

import Foundation

struct GameOnline: Codable, Identifiable {
    let id: String
    
    let player1Id: String
    var player2Id: String
    
    var player1Score: Int
    var player2Score: Int
    
    var winningPlayerId: String
    var currentPlayerId: String
    
    var moves: [GameMove?]
}
