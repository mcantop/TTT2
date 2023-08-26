//
//  FactorySetup.swift
//  TTT2Tests
//
//  Created by Maciej on 26/08/2023.
//

import Foundation
import Factory
@testable import TTT2

extension Container {
    static func setupMocks(shouldReturnNil: Bool = false) {
        Container.shared.firebaseRepository.register {
            MockFirebaseRepository(shouldReturnNil: shouldReturnNil)
        }
    }
}
