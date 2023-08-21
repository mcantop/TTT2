//
//  GameViewModel.swift
//  TTT2
//
//  Created by Maciej on 16/08/2023.
//

import SwiftUI
import Combine

final class GameViewModel: ObservableObject {
    // MARK: - Online Game Properties
    @Published private(set) var showingLoadingIndicator = false
    @Published private(set) var gameOnline: GameOnline?
    let onlineRepository = OnlineGameRepository()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Properties
    @Published var presentingAlert = false {
        didSet {
            print("[DEBUG] didSet presentingAlert \(presentingAlert)")
        }
    }
    @Published private(set) var alertItem: AlertItem? {
        didSet {
            presentingAlert = true
        }
    }
    @Published private(set) var isGameBoardDisabled = false
    @Published private(set) var shouldDismiss = false
    @Published private(set) var gameMode: GameMode
    @Published private(set) var moves: [GameMove?] = Array(repeating: nil, count: 9)
    @Published private(set) var player1Name = ""
    @Published private(set) var player2Name = ""
    @Published private(set) var player1Score = 0
    @Published private(set) var player2Score = 0
    @Published private(set) var currentPlayer: Player = .player1
    @Published var players: [Player] = [.player1]

    let columns: [GridItem] = [.init(spacing: 16), .init(spacing: 16), .init(spacing: 16)]
        
    var gameModeName: String {
        return gameMode == .cpu
        ? gameMode.rawValue.uppercased()
        : gameMode.rawValue.capitalized
    }
    
    private let winPatterns: Set<Set<Int>> = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], /// Horizontal
        [0, 3, 6], [1, 4, 7], [2, 5, 8], /// Vertical
        [0, 4, 8], [2, 4, 6] /// Diagonal
    ]
    
    // MARK: - Init
    init(gameMode: GameMode) {
        self.gameMode = gameMode
        
        switch gameMode {
        case .local:
            players.append(.player2)
        case .cpu:
            players.append(.cpu)
        case .online:
            players.append(.player2)
            startOnlineGame()
            observeOnlineUpdateLocal()
        }
        
        assignPlayerNames()
    }
}

// MARK: - Public API
extension GameViewModel {
    func processMove(position: Int) {
        /// Firstly, check if position is already occupied.
        guard !isOccupied(position: position) else {
            return
        }
        
        /// Then, assign a new move to the board.
        moves[position] = GameMove(player: currentPlayer, position: position)
        
        if isGameOver() {
            return
        }
        
        /// Finally, if game isn't over
        /// Switch the player for the other.
        switchPlayer()
        
        if gameMode == .cpu && currentPlayer == .cpu {
            isGameBoardDisabled.toggle()
            cpuMove()
        }
        
        updateOnlineGame(process: .move)
    }
    
    func handleRematch() {
        currentPlayer = .player1
        
        withAnimation(.spring()) {
            moves = Array(repeating: nil, count: 9)
        }
        
        if gameMode == .online {
            updateOnlineGame(process: .reset)
        }
    }
    
    func quitGame() {
        shouldDismiss.toggle()
        onlineRepository.quitGame()
    }
}

// MARK: - Private API
private extension GameViewModel {
    func isOccupied(position: Int) -> Bool {
        return moves.contains(where: { $0?.position == position })
    }
    
    func isGameOver() -> Bool {
        if didWon() {
            increaseScore()
            presentAlert(for: .finished)
            updateOnlineGame(process: .win)
            return true
        }
        
        if didDraw() {
            presentAlert(for: .draw)
            updateOnlineGame(process: .draw)
            return true
        }
        
        return false
    }
    
    func didWon() -> Bool {
        let playerMoves = getMoves(for: currentPlayer)
        let playerPositions = Set(playerMoves
            .map { $0.position }
        )
        
        return winPatterns.contains { $0.isSubset(of: playerPositions) }
    }
    
    func didDraw() -> Bool {
        /// If it doesn't contain nils, that means all moves has been occupied and no more turns are left.
        return !moves.contains(where: { $0 == nil})
    }
    
    func switchPlayer() {
        if let nextPlayer = players.first(where: { $0 != currentPlayer}) {
            currentPlayer = nextPlayer
        }
    }
    
    func increaseScore() {
        if currentPlayer == .player1 {
            player1Score += 1
        } else {
            player2Score += 1
        }
    }
    
    func presentAlert(for gameState: GameState) {
        var buttons: [AlertButton] = [.init(type: .quit) {
            self.quitGame()
        }]
        
        if gameState != .playerQuit {
            buttons.insert(.init(type: .rematch) { self.handleRematch() }, at: 0)
        }
        
        self.alertItem = AlertItem(
            title: gameState.createAlertTitle(for: currentPlayer),
            message: gameState.createAlertMessage(for: currentPlayer),
            buttons: buttons
        )
        
        print("[DEBUG] presetAlert buttons \(buttons)")
    }
    
    func getMoves(for player: Player) -> [GameMove] {
        return moves
            .compactMap { $0 }
            .filter { $0.player == player }
    }
    
    func assignPlayerNames() {
        switch gameMode {
        case .local:
            player1Name = "Player 1"
            player2Name = "Player 2"
        case .cpu:
            player1Name = "You"
            player2Name = "CPU"
        case .online:
            player1Name = localPlayerId == gameOnline?.player1Id ? "You" : "Player 1"
            player2Name = localPlayerId == gameOnline?.player2Id ? "You" : "Player 2"
        }
    }
}

// MARK: - Private CPU API
private extension GameViewModel {
    func cpuMove() {
        let randomisedDelay = Double.random(in: 0.5 ... 1.5)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + randomisedDelay) { [self] in
            processMove(position: getAIMovePosition())
            isGameBoardDisabled.toggle()
        }
    }
    
    func getAIMovePosition() -> Int {
        /// Get CPU position(s).
        let cpuMoves = getMoves(for: .cpu)
        let cpuPositions = Set(cpuMoves
            .map { $0.position }
        )
        
        /// Check if can win.
        if let winningPosition = getWinningPosition(for: cpuPositions) {
            return winningPosition
        }
        
        /// Check if can block human.
        let humanMoves = getMoves(for: .player1)
        let humanPositions = Set(humanMoves
            .map { $0.position }
        )
        
        if let blockingPosition = getWinningPosition(for: humanPositions) {
            return blockingPosition
        }
        
        /// Check if can take the center square (important in Tic Tac Toe).
        let centerSquare = 4
        if !isOccupied(position: centerSquare) {
            return centerSquare
        }
        
        /// Finally, take a random number
        var randomPosition = Int.random(in: 0..<9)
        while isOccupied(position: randomPosition) {
            randomPosition = Int.random(in: 0..<9)
        }
        
        return randomPosition
    }
    
    func getWinningPosition(for positions: Set<Int>) -> Int? {
        for winPattern in winPatterns {
            let winPositions = winPattern.subtracting(positions)
            
            if
                let winPosition = winPositions.first,
                winPositions.count == 1 && !isOccupied(position: winPosition)
            {
                return winPosition
            }
        }
        
        return nil
    }
}

// MARK: - Private Online API
private extension GameViewModel {
    func observeOnlineUpdateLocal() {
        onlineRepository.$gameOnline
            .map { $0 }
            .assign(to: &$gameOnline)
        
        $gameOnline
            .map { $0?.moves ?? Array(repeating: nil, count: 9) }
            .assign(to: &$moves)
        
        $gameOnline
            .map { $0?.player1Score ?? 0 }
            .assign(to: &$player1Score)
        
        $gameOnline
            .map { $0?.player2Score ?? 0 }
            .assign(to: &$player2Score)
        
        $gameOnline
            .drop(while: { $0 == nil })
            .map { $0?.player2Id == "" }
            .assign(to: &$showingLoadingIndicator)
        
        $gameOnline
            .drop(while: { $0 == nil })
            .sink { updatedGame in
                self.syncOnlineWithLocal(gameOnline: updatedGame)
            }
            .store(in: &subscriptions)
        
        /// Update player names.
        $gameOnline
            .map { $0?.player2Id ?? $0?.player1Id }
            .sink { _ in
                self.assignPlayerNames()
            }
            .store(in: &subscriptions)
    }
    
    func startOnlineGame() {
        Task {
            await onlineRepository.startOnlineGameFlow()
        }
    }
    
    func updateOnlineGame(process: GameOnlineProcess) {
        guard var tempGame = gameOnline else { return }
        
        isGameBoardDisabled = localPlayerId != tempGame.currentPlayerId
        
        tempGame.currentPlayerId = tempGame.currentPlayerId == tempGame.player1Id
        ? tempGame.player2Id
        : tempGame.player1Id
        
        tempGame.player1Score = player1Score
        tempGame.player2Score = player2Score
        
        switch process {
        case .win:
            tempGame.winningPlayerId = localPlayerId
        case .draw:
            tempGame.winningPlayerId = "0"
            tempGame.currentPlayerId = tempGame.player1Id
        case .reset:
            tempGame.winningPlayerId = ""
            tempGame.currentPlayerId = tempGame.player1Id
        case .move:
            break
        }
        
        tempGame.moves = moves
        onlineRepository.updateGame(tempGame)
    }
    
    func syncOnlineWithLocal(gameOnline: GameOnline?) {
        guard let gameOnline else {
            /// If game is nil, show alert that other user left.
            presentAlert(for: .playerQuit)
            return
        }

        if gameOnline.winningPlayerId == "0" {
            /// Draw.
            presentAlert(for: .draw)
        } else if gameOnline.winningPlayerId != "" {
            /// Win.
            presentAlert(for: .finished)
        }

        /// Disable board.
        isGameBoardDisabled = gameOnline.player2Id.isEmpty ? true : localPlayerId != gameOnline.currentPlayerId
        
        switchPlayerOnline(gameOnline)
    }
    
    func switchPlayerOnline(_ gameOnline: GameOnline) {
        if localPlayerId == gameOnline.player1Id {
            if localPlayerId == gameOnline.currentPlayerId {
                currentPlayer = .player1
            }
        } else {
            if localPlayerId == gameOnline.currentPlayerId {
                currentPlayer = .player2
            }
        }
    }
}
