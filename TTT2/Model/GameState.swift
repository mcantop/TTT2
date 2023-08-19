//
//  GameState.swift
//  TTT2
//
//  Created by Maciej on 19/08/2023.
//

import Foundation

enum GameState {
    case finished
    case draw
    case waitingForPlayer
    case playerQuit
    
    func createAlertTitle(for player: Player) -> String {
        switch self {
        case .finished:
            switch player {
            case .player1:
                return "You win!"
            default:
                return "\(player.name) wins!"
            }
        case .draw:
            return "It's a draw!"
        case .waitingForPlayer:
            return "Waiting.."
        case .playerQuit:
            return "Player left the game.."
        }
    }
    
    func createAlertMessage(for player: Player) -> String {
        switch self {
        case .finished:
            switch player {
            case .player1:
                return "You get one point."
            default:
                return "\(player.name) gets one point."
            }
        case .draw:
            return "Try again?"
        case .waitingForPlayer:
            return "for an other player to join.."
        case .playerQuit:
            return "Please join another game room."
        }
    }
}
