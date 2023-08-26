//
//  OnlineGameTests.swift
//  TTT2Tests
//
//  Created by Maciej on 26/08/2023.
//

import XCTest
import Factory
import Combine
@testable import TTT2

final class OnlineGameTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable> = []
    
    func test_startOnlineFlowReturnsReadyGame() async {
        Container.setupMocks()
        
        let sut = OnlineGameRepository()
        
        sut.$gameOnline
            .dropFirst()
            .sink { newValue in
                XCTAssertEqual(newValue?.id, "mockId")
                XCTAssertEqual(newValue?.player1Id, "player1MockId")
            }
            .store(in: &subscriptions)
        
        await sut.startOnlineGameFlow()
    }
    
    func test_startOnlineFlowCreatesNewGame() async {
        Container.setupMocks(shouldReturnNil: true)
        
        let sut = OnlineGameRepository()
        
        sut.$gameOnline
            .dropFirst()
            .sink { newValue in
                XCTAssertEqual(newValue?.player2Id, "")
            }
            .store(in: &subscriptions)
        
        await sut.startOnlineGameFlow()
    }
}
