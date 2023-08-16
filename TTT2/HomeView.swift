//
//  ContentView.swift
//  TTT2
//
//  Created by Maciej on 16/08/2023.
//

import SwiftUI

private enum TitlePart: String, Identifiable, CaseIterable {
    case tic
    case tac
    case toe
    
    var id: String {
        return self.rawValue
    }
}

struct HomeView: View {
    @State private var gameMode: GameMode?
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            
            Spacer()
            
            selectGameModeView
        }
        .padding(.vertical)
        .fullScreenCover(item: $gameMode) { mode in
            GameView(gameMode: mode)
        }
    }
    
    private var titleView: some View {
        HStack(spacing: 12) {
            Image(systemName: "number")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: .infinity)
            
            VStack(alignment: .leading) {
                ForEach(TitlePart.allCases) { part in
                    Text(part.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxHeight: .infinity)
                }
            }
        }
        .frame(maxHeight: 100)
    }
    
    private var selectGameModeView: some View {
        VStack(spacing: 24) {
            Text("Choose your game mode")
                .font(.headline)
            
            ForEach(GameMode.allCases) { mode in
                WideButton(mode.rawValue, image: mode.image) {
                    gameMode = mode
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
