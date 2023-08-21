//
//  FirebaseCollectionRef.swift
//  TTT2
//
//  Created by Maciej on 20/08/2023.
//

import Foundation
import Firebase

enum FirebaseCollectionRef: String {
    case game
}

func FirebaseRef(_ reference: FirebaseCollectionRef) -> CollectionReference {
    return Firestore.firestore().collection(reference.rawValue)
}
