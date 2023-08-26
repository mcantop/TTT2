//
//  GameViewModelTests.swift
//  GameViewModelTests
//
//  Created by Maciej on 16/08/2023.
//

import XCTest
import Factory
import Combine
@testable import TTT2

final class GameViewModelTests: XCTestCase {
    var sut = GameViewModel(gameMode: .local, onlineRepository: OnlineGameRepository())
    
    private var subscriptions: Set<AnyCancellable> = []
    
    func test_RematchSetsTheActivePlayerToPlayer1() {
        sut.handleRematch()
        
        XCTAssertEqual(sut.currentPlayer, .player1)
    }
    
    func test_RematchSetsMovesToNineNilObjects() {
        sut.handleRematch()
        
        XCTAssertEqual(sut.moves, Array(repeating: nil, count: 9))
    }
    
    func test_ProcessMoveWillPresentAlertWhenGameFinished() {
        for index in 0..<9 {
            sut.processMove(position: index)
        }
        
        XCTAssertNotNil(sut.alertItem)
        XCTAssertTrue(sut.presentingAlert)
    }
    
    func test_ProcessMoveWillReturnForOccupiedSquare() {
        sut.processMove(position: .zero)
        sut.processMove(position: .zero)
        
        let movesWithoutNil = sut.moves.compactMap { $0 }
        
        XCTAssertEqual(movesWithoutNil.count, 1)
    }
    
    func test_Player1WinWillIncreaseScore() {
        XCTAssertEqual(sut.player1Score, 0)
        
        letPlayer1Win()
        
        XCTAssertEqual(sut.player1Score, 1)
    }
    
    func test_Player2WinWillIncreaseScore() {
        XCTAssertEqual(sut.player2Score, 0)
        
        letPlayer2Win()
        
        XCTAssertEqual(sut.player2Score, 1)
    }
    
    func test_PlayersScoreEqualsZeroAfterDraw() {
        letPlayersDraw()
        
        XCTAssertEqual(sut.player1Score, 0)
        XCTAssertEqual(sut.player2Score, 0)
    }
    
    func test_CPUWillTakeTheMiddleSpotAfterPlayerMove() {
        let centerSquare = 4
        let maximumWaitingTime = 1.5
        let expectation = expectation(description: "Waiting for CPU move")
        
        sut = GameViewModel(gameMode: .cpu, onlineRepository: OnlineGameRepository())
        
        sut.processMove(position: 0) /// Human Player Move
        
        DispatchQueue.main.asyncAfter(deadline: .now() + maximumWaitingTime) {
            XCTAssertNotNil(self.sut.moves[centerSquare])
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: maximumWaitingTime)
    }
    
    func test_PlayerNamesInGameModeLocal() {
        XCTAssertEqual(sut.player1Name, "Player 1")
        XCTAssertEqual(sut.player2Name, "Player 2")
    }
    
    func test_PlayerNamesInGameModeCPU() {
        sut = GameViewModel(gameMode: .cpu, onlineRepository: OnlineGameRepository())
        
        XCTAssertEqual(sut.player1Name, "You")
        XCTAssertEqual(sut.player2Name, "CPU")
    }
    
    // TODO: - Fix this test
    func test_PlayerNamesInGameModeOnlineIfCreatingGame() {
//        Container.setupMocks(shouldReturnNil: true)
//        
//        let onlineRepository = OnlineGameRepository()
//        let expectation = expectation(description: "Waiting for names update")
//        let time = 1.0
//
//        sut = GameViewModel(gameMode: .online, onlineRepository: onlineRepository)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
//            print(localPlayerId)
//            XCTAssertEqual(self.sut.player1Name, "You")
//            XCTAssertEqual(self.sut.player2Name, "Player 2")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: time)
    }
    
    func test_PlayerNamesInGameModeOnlineIfJoiningGame() {
        Container.setupMocks(shouldReturnNil: false)
        
        let onlineRepository = OnlineGameRepository()
        let expectation = expectation(description: "Waiting for names update")
        let time = 1.0
        
        sut = GameViewModel(gameMode: .online, onlineRepository: onlineRepository)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            XCTAssertEqual(self.sut.player1Name, "Player 1")
            XCTAssertEqual(self.sut.player2Name, "You")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: time)
    }
}

// MARK: - Private API
private extension GameViewModelTests {
    func letPlayer1Win() {
        // X - O
        // X - O
        // X
        sut.processMove(position: 0) /// P1
        sut.processMove(position: 1) /// P2
        sut.processMove(position: 3) /// P1
        sut.processMove(position: 4) /// P2
        sut.processMove(position: 6) /// P1
    }
    
    func letPlayer2Win() {
        // X - O -
        // X - O -
        //   - O - X
        sut.processMove(position: 0) /// P1
        sut.processMove(position: 1) /// P2
        sut.processMove(position: 3) /// P1
        sut.processMove(position: 4) /// P2
        sut.processMove(position: 8) /// P1
        sut.processMove(position: 7) /// P2
    }
    
    func letPlayersDraw() {
        // X - O - X
        // O - X - X
        // O - X - O
        sut.processMove(position: 0) /// P1
        sut.processMove(position: 1) /// P2
        sut.processMove(position: 2) /// P1
        sut.processMove(position: 3) /// P2
        sut.processMove(position: 4) /// P1
        sut.processMove(position: 6) /// P2
        sut.processMove(position: 5) /// P1
        sut.processMove(position: 8) /// P2
        sut.processMove(position: 7) /// P1
    }
}
