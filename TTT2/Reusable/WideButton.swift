//
//  WideButton.swift
//  TTT2
//
//  Created by Maciej on 16/08/2023.
//

import SwiftUI

struct WideButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let image: Image?
    let action: () -> Void
    
    init(_ title: String, image: Image? = nil, action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.action = action
    }
    
    private var backgroundColor: Color {
        return colorScheme == .light ? .cyan : .blue
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if let image {
                    image
                }
                
                Text(title.uppercased())
            }
            .font(.title)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .tracking(2)
            .foregroundColor(.primary)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(backgroundColor.opacity(0.87))
            .clipShape(Capsule())
        }
    }
}

struct WideButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WideButton("Online") { }
            WideButton("Online", image: SFSymbol.network.image) { }
        }
    }
}
