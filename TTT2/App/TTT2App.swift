//
//  TTT2App.swift
//  TTT2
//
//  Created by Maciej on 16/08/2023.
//

import SwiftUI
import Firebase

@main
struct TTT2App: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
