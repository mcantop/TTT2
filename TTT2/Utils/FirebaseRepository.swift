//
//  FirebaseRepository.swift
//  TTT2
//
//  Created by Maciej on 20/08/2023.
//

import Foundation
import FirebaseFirestoreSwift
import Combine

public typealias EncodableIdentifiable = Encodable & Identifiable

protocol FirebaseRepositoryProtocol {
    func getDocuments<T: Codable>(from collection: FirebaseCollectionRef, for playerId: String) async throws -> [T]?
    func listen<T: Codable>(from collection: FirebaseCollectionRef, documentId: String) async throws -> AnyPublisher<T?, Error>
    func deleteDocument(with id: String, from collection: FirebaseCollectionRef)
    func saveData<T: EncodableIdentifiable>(data: T, to collection: FirebaseCollectionRef) throws
}

final class FirebaseRepository: FirebaseRepositoryProtocol {
    func getDocuments<T: Codable>(from collection: FirebaseCollectionRef, for playerId: String) async throws -> [T]? {
        let snapshot = try await FirebaseRef(collection)
            .whereField("player2Id", isEqualTo: "")
            .whereField("player1Id", isNotEqualTo: playerId)
            .getDocuments()
        
        return snapshot.documents.compactMap { queryDocumentSnapshot -> T? in
            return try? queryDocumentSnapshot.data(as: T.self)
        }
    }
    
    func listen<T: Codable>(from collection: FirebaseCollectionRef, documentId: String) async throws -> AnyPublisher<T?, Error> {
        let subject = PassthroughSubject<T?, Error>()
        let handler = FirebaseRef(collection)
            .document(documentId)
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let document = querySnapshot else {
                    subject.send(completion: .failure(AppError.badSnapshot))
                    return
                }
                
                let data = try? document.data(as: T.self)
                
                subject.send(data)
            }
        
        return subject.handleEvents(receiveCancel: {
            handler.remove()
        }).eraseToAnyPublisher()
    }
    
    func deleteDocument(with id: String, from collection: FirebaseCollectionRef) {
        FirebaseRef(collection).document(id).delete()
    }
    
    func saveData<T: EncodableIdentifiable>(data: T, to collection: FirebaseCollectionRef) throws {
        let id = data.id as? String ?? UUID().uuidString

        do {
            try FirebaseRef(collection).document(id).setData(from: data.self)
        } catch {
            throw error
        }
    }
}
