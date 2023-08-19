//
//  AlertItem.swift
//  TTT2
//
//  Created by Maciej on 19/08/2023.
//

import SwiftUI

enum AlertButtonType: String {
    case rematch
    case quit
}

struct AlertButton: Identifiable {
    let id = UUID()
    let type: AlertButtonType
    let action: () -> Void
    
    var role: ButtonRole {
        switch type {
        case .quit:
            return .destructive
        default:
            return .cancel
        }
    }

    var label: Text {
        return Text(type.rawValue.capitalized)
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let buttons: [AlertButton]
}
