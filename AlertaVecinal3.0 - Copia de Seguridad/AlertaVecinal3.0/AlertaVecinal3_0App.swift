//
//  AlertaVecinal3_0App.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/22/25.
//

import SwiftUI

@main
struct AlertaVecinal3_0App: App {
    @StateObject var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack{
                    LoginView()
                }
            }
        }
        .environmentObject(authManager)
    }
}

