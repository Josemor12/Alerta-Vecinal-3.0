//
//  MainTabView.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/23/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "house")
                }
            
            MapView()
                .tabItem {
                    Label("Mapa", systemImage: "map")
                }
            
            CommunityChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person")
                          
                }
        }
    }
}
