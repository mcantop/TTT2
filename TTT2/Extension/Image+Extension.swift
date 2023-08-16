//
//  Image+Extension.swift
//  TTT2
//
//  Created by Maciej on 16/08/2023.
//

import SwiftUI

typealias SFSymbol = Image.SFSymbol

extension Image {
    enum SFSymbol: String {
        case house
        case cpu
        case network
        
        var image: Image {
            return Image(systemName: self.rawValue)
        }
    }
}
