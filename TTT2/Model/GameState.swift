//
//  GameState.swift
//  TTT2
//
//  Created by Maciej on 19/08/2023.
//

import Foundation

enum GameState: Equatable {
    case finished
    case draw
    case waitingForPlayer
    case playerQuit
    
    func createAlertStrings(gameMode: GameMode, currentPlayer: Player, didLocalPlayerWin: Bool? = nil) -> (title: String, message: String) {
        let title: String
        let message: String
        
        switch self {
        case .finished:
            switch gameMode {
            case .local, .cpu:
                let isYou = currentPlayer == .player1 && gameMode == .cpu
                title = isYou ? "You win!" : "\(currentPlayer.name) wins!"
                message = isYou ? "You get a point." : "\(currentPlayer.name) gets a point."
            case .online:
                let didLocalPlayerWin = didLocalPlayerWin == true
                title = didLocalPlayerWin ? "You win!" : "You lose!"
                message = didLocalPlayerWin ? "You get a point." : "\(currentPlayer.name) gets a point."
            }
        case .draw:
            title = "It's a draw!"
            message = "Do you want to rematch?"
        case .waitingForPlayer:
            title = ""
            message = ""
        case .playerQuit:
            title = "Other player quit!"
            message = "Please join another game."
        }
        
        return (title: title, message: message)
    }
}
