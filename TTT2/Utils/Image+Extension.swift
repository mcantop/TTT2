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
        
        case number
        case hand_point_up_left
        case hand_point_up_left_fill
        
        case trophy
        
        var image: Image {
            return Image(systemName: self.rawValueWithoutDashes)
        }
        
        private var rawValueWithoutDashes: String {
            return self.rawValue.replacingOccurrences(of: "_", with: ".")
        }
    }
}
