//
//  OnlineGameRepository.swift
//  TTT2
//
//  Created by Maciej on 20/08/2023.
//

import Foundation
import Combine
import Factory

let localPlayerId = UUID().uuidString

final class OnlineGameRepository: ObservableObject {
    @Injected(\.firebaseRepository) private var firebaseRepository
    
    @Published var gameOnline: GameOnline!
    
    private var subscriptions: Set<AnyCancellable> = []
}

// MARK: - Public API
extension OnlineGameRepository {
    @MainActor
    func startOnlineGameFlow() async {
        if let gameToJoin = await getGame() {
            /// Firstly update game locally (setup 2nd player).
            /// Then update game online (for the 1st player).
            /// And listen for changes.
            
            gameOnline = gameToJoin
            gameOnline.player2Id = localPlayerId
            gameOnline.currentPlayerId = gameOnline.player1Id
            
            updateGame(gameOnline)
            await listenForChanges(in: gameOnline.id)
        } else {
            /// If no games have been found, create one locally.
            /// Then listen for changes (waiting for other players to join).
            
            await createGame()
            await listenForChanges(in: gameOnline.id)
        }
    }
    
    func updateGame(_ game: GameOnline) {
        do {
            try firebaseRepository.saveData(data: game, to: .game)
        } catch {
            print("[DEBUG] Error updating game - \(error.localizedDescription)")
        }
    }
    
    func quitGame() {
        guard gameOnline != nil else { return }
        firebaseRepository.deleteDocument(with: gameOnline.id, from: .game)
    }
}

// MARK: - Private API
private extension OnlineGameRepository {
    func getGame() async -> GameOnline? {
        return try? await firebaseRepository.getDocuments(from: .game, for: localPlayerId)?.first
    }
    
    @MainActor
    func createGame() async {
        gameOnline = GameOnline(
            id: UUID().uuidString,
            player1Id: localPlayerId,
            player2Id: "",
            player1Score: 0,
            player2Score: 0,
            winningPlayerId: "",
            currentPlayerId: "",
            moves: Array(repeating: nil, count: 9)
        )
        
        updateGame(gameOnline)
    }
    
    @MainActor
    func listenForChanges(in gameId: String) async {
        do {
            try await firebaseRepository.listen(from: .game, documentId: gameId)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        return
                    case .failure(let error):
                        print("[DEBUG] Error receiving changes from listening - \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] game in
                    self?.gameOnline = game
                })
                .store(in: &subscriptions)
        } catch {
            print("[DEBUG] Error listening for changes - \(error.localizedDescription)")
        }
    }
}
