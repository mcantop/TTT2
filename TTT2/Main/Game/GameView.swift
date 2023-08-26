//
//  GameView.swift
//  TTT2
//
//  Created by Maciej on 16/08/2023.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: GameViewModel
    
    @Namespace private var playerTurnAnimation
    
    var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
                statsView
                    .frame(maxHeight: .infinity)
                
                boardView
                    .padding(.horizontal)
            }
            // MARK: - Alert
            .alert(viewModel.alertItem?.title ?? "", isPresented: $viewModel.presentingAlert) {
                ForEach(viewModel.alertItem?.buttons ?? []) { button in
                    Button {
                        button.action()
                    } label: {
                        button.label
                    }
                }
            } message: {
                Text(viewModel.alertItem?.message ?? "")
            }
            .onChange(of: viewModel.shouldDismiss) { _ in /// Passing dismiss value.
                dismiss()
            }
            /// Handling dismissing alert for the second player,
            /// After the first one taps 'Rematch'.
            .onChange(of: viewModel.gameOnline?.winningPlayerId) { newPlayerId in
                if viewModel.presentingAlert && newPlayerId == "" {
                    viewModel.presentingAlert = false
                }
            }
            
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        viewModel.gameMode.image
                        
                        Text(viewModel.gameModeName)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Quit") {
                        viewModel.quitGame()
                    }
                }
            }
        }
    }
    
    private var statsView: some View {
        HStack(alignment: .bottom) {
            ForEach(viewModel.players) { player in
                playerStatsView(player)
                    .frame(maxWidth: .infinity)
            }
        }
        .animation(.spring(), value: viewModel.currentPlayer)
    }
    
    private func playerStatsView(_ player: Player) -> some View {
        VStack(alignment: .center, spacing: 12) {
            if viewModel.currentPlayer == player {
                SFSymbol.hand_point_up_left_fill.image
                    .matchedGeometryEffect(id: "Off", in: playerTurnAnimation)
            } else {
                SFSymbol.hand_point_up_left.image
                    .opacity(0.25)
            }
            
            VStack(spacing: 6) {
                let isPlayer1 = player == .player1
                
                Text(isPlayer1
                     ? viewModel.player1Name
                     : viewModel.player2Name
                )
                .fontWeight(.semibold)
                
                HStack {
                    if isPlayer1 {
                        Text(String(viewModel.player1Score))
                    }
                    
                    SFSymbol.trophy.image
                    
                    if !isPlayer1 {
                        Text(String(viewModel.player2Score))
                    }
                }
            }
        }
        .font(.title2)
    }
    
    private var boardView: some View {
        ZStack(alignment: .top) {
            if viewModel.showingLoadingIndicator {
                Text("Waiting for other player to join..")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                    .padding(.top, -32)
            }
            
            LazyVGrid(columns: viewModel.columns, spacing: 16) {
                ForEach(0..<9) { position in
                    Button {
                        viewModel.processMove(position: position)
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 3)
                                .background(.ultraThickMaterial)
                                .clipShape(Circle())
                                .shadow(color: .primary.opacity(0.15), radius: 3)
                            
                            BoardIndicatorView(imageName: viewModel.moves[position]?.type ?? "")
                        }
                    }
                }
            }
            .overlay(
                ProgressView()
                    .controlSize(.large)
                    .opacity(viewModel.showingLoadingIndicator ? 1 : 0)
            )
            .disabled(viewModel.isGameBoardDisabled)
            .animation(.spring(), value: viewModel.isGameBoardDisabled)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GameView(
                viewModel: GameViewModel(
                    gameMode: .cpu,
                    onlineRepository: OnlineGameRepository()
                )
            )
        }
    }
}

private enum PlayerStatistic: CaseIterable, Identifiable {
    case player1
    case player2
    
    var id: UUID {
        return .init()
    }
}
