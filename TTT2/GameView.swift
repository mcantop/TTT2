//
//  GameView.swift
//  TTT2
//
//  Created by Maciej on 16/08/2023.
//

import SwiftUI

struct GameView: View {
    let gameMode: GameMode
    
    var body: some View {
        Text("Game Mode: \(gameMode.rawValue)")
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(gameMode: .online)
    }
}
