//
//  MockFirebaseRepository.swift
//  TTT2
//
//  Created by Maciej on 26/08/2023.
//

import Foundation
import Combine

final class MockFirebaseRepository: FirebaseRepositoryProtocol {
    let dummyGame = GameOnline(
        id: "mockId",
        player1Id: "player1MockId",
        player2Id: "player2MockId",
        player1Score: 3,
        player2Score: 4,
        winningPlayerId: "",
        currentPlayerId: "player1MockId",
        moves: Array(repeating: nil, count: 9)
    )
    
    var returnNil = false
    
    init(shouldReturnNil: Bool = false) {
        returnNil = shouldReturnNil
    }
    
    func getDocuments<T>(from collection: FirebaseCollectionRef, for playerId: String) async throws -> [T]? where T : Decodable, T : Encodable {
        print("[DEBUG] Sending Mock")
        
        return returnNil ? nil : [dummyGame] as? [T]
    }
    
    func listen<T>(from collection: FirebaseCollectionRef, documentId: String) async throws -> AnyPublisher<T?, Error> where T : Decodable, T : Encodable {
        let subject = PassthroughSubject<T?, Error>()
        
        subject.send(dummyGame as? T)
        
        return subject.eraseToAnyPublisher()
    }
    
    func deleteDocument(with id: String, from collection: FirebaseCollectionRef) { }
    
    func saveData<T>(data: T, to collection: FirebaseCollectionRef) throws where T : Encodable, T : Identifiable { }
}

