//
//  ServiceDependencies.swift
//  TTT2
//
//  Created by Maciej on 20/08/2023.
//

import Foundation
import Factory

extension Container {
    var firebaseRepository: Factory<FirebaseRepositoryProtocol> {
        self {
            FirebaseRepository()
        }
        .shared
    }
}
