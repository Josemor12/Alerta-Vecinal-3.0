//
//  DashboardView.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/23/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showEmergencyAlert = false
    @State private var showQuickActions = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Text("¿Necesitas ayuda urgente?")
                            .font(.headline)
                        
                        Button(action: {
                            showEmergencyAlert = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 30))
                                Text("EMERGENCIA")
                                    .font(.headline.bold())
                            }
                            .frame(width: 180, height: 180)
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .top, endPoint: .bottom))
                            .clipShape(Circle())
                            .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 5)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                        }
                        .alert("Confirmar emergencia", isPresented: $showEmergencyAlert) {
                            Button("Cancelar", role: .cancel) {}
                            Button("Confirmar", role: .destructive) {
                                // Acción de emergencia
                            }
                        } message: {
                            Text("¿Estás seguro que deseas activar una alerta de emergencia? Se notificará a las autoridades y vecinos cercanos.")
                        }
                        
                        Text("Presiona en caso de peligro inminente")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                    
                    DisclosureGroup("Acciones rápidas", isExpanded: $showQuickActions) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                            ActionButton(icon: "map.fill", label: "Mapa", color: .blue, destination: MapView())
                            ActionButton(icon: "bell.fill", label: "Alertas", color: .orange, destination: NotificationsView())
                            ActionButton(icon: "person.fill", label: "Perfil", color: .green, destination: ProfileView())
                            ActionButton(icon: "megaphone.fill", label: "Reportar", color: .purple, destination: MapView())
                        }
                        .padding(.top)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Alertas recientes")
                                .font(.headline)
                            Spacer()
                            NavigationLink("Ver todas") {
                                MapView()
                            }
                            .font(.subheadline)
                        }
                        
                        if recentAlerts.isEmpty {
                            Text("No hay alertas recientes")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(recentAlerts.prefix(3)) { alert in
                                AlertCard(alert: alert)
                            }
                        }
                    }
                    .padding()
                }
                .padding(.vertical)
            }
            .navigationTitle("Menú Principal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authManager.logout()
                    }) {
                        Label("Salir", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
    
    private var recentAlerts: [AlertItem] {
        [
            AlertItem(title: "Robo reportado", message: "Se reportó un robo en Calle Principal a las 15:30", type: .critical, time: "Hace 30 min"),
        ]
    }
}

struct ActionButton<Destination: View>: View {
    var icon: String
    var label: String
    var color: Color
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .symbolVariant(.fill)
                    .foregroundColor(color)
                Text(label)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 90)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct AlertCard: View {
    var alert: AlertItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: alert.type.icon)
                .foregroundColor(alert.type.color)
                .frame(width: 24, height: 24)
                .padding(8)
                .background(alert.type.color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.title)
                        .font(.subheadline.bold())
                    Spacer()
                    Text(alert.time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: AlertType
    let time: String
}

enum AlertType {
    case critical, warning, info, community
    
    var icon: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        case .community: return "person.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .warning: return .orange
        case .info: return .blue
        case .community: return .green
        }
    }
}
