//
//  BoardIndicatorView.swift
//  TTT2
//
//  Created by Maciej on 18/08/2023.
//

import SwiftUI

struct BoardIndicatorView: View {
    @State private var scale = 1.0
    
    let imageName: String
    private let width = UIScreen.main.bounds.width / 9
    
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .onChange(of: imageName) { _ in
                scale = 2
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scale = 1.5
                }
            }
            .frame(maxWidth: width)
            .animation(.spring(), value: scale)
    }
}

struct BoardIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        BoardIndicatorView(imageName: "applelogo")
    }
}
