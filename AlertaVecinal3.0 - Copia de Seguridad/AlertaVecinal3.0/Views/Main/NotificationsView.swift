//
//  NotificationsView.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/25/25.
//

import SwiftUI

struct NotificationsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("notificationPreview") private var notificationPreview = NotificationPreviewType.partial
    @AppStorage("quietHoursEnabled") private var quietHoursEnabled = false
    @AppStorage("quietHoursFrom") private var quietHoursFrom = Date(timeIntervalSinceReferenceDate: 0)
    @AppStorage("quietHoursTo") private var quietHoursTo = Date(timeIntervalSinceReferenceDate: 0)
    
    enum NotificationPreviewType: String, CaseIterable {
        case full = "Mostrar todo el contenido"
        case partial = "Mostrar solo remitente"
        case none = "No mostrar contenido"
    }
    
    var body: some View {
        Form {
            Section(header: Text("CONFIGURACIÓN GENERAL").font(.caption)) {
                Toggle("Notificaciones activas", isOn: $notificationsEnabled)
                    .tint(.blue)
                
                if notificationsEnabled {
                    Toggle("Sonido", isOn: $soundEnabled)
                        .tint(.blue)
                    
                    Toggle("Vibración", isOn: $vibrationEnabled)
                        .tint(.blue)
                    
                    Picker("Vista previa de notificaciones", selection: $notificationPreview) {
                        ForEach(NotificationPreviewType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .headerProminence(.increased)
            
            Section(header: Text("HORARIOS SILENCIOSOS").font(.caption)) {
                Toggle("Activar horarios silenciosos", isOn: $quietHoursEnabled)
                    .tint(.blue)
                
                if quietHoursEnabled {
                    DatePicker("Desde", selection: $quietHoursFrom, displayedComponents: .hourAndMinute)
                    DatePicker("Hasta", selection: $quietHoursTo, displayedComponents: .hourAndMinute)
                    
                    InfoText("No recibirás notificaciones durante este horario, excepto emergencias")
                }
            }
            .headerProminence(.increased)
            
            Section(header: Text("TIPOS DE NOTIFICACIONES").font(.caption)) {
                NavigationLink {
                    EmergencyAlertsView()
                } label: {
                    SettingsRow(icon: "exclamationmark.triangle", title: "Alertas de Emergencia", color: .red)
                }
                
                NavigationLink {
                    CommunityAlertsView()
                } label: {
                    SettingsRow(icon: "person.2", title: "Alertas Comunitarias", color: .green)
                }
                
                NavigationLink {
                    ActivityNotificationsView()
                } label: {
                    SettingsRow(icon: "bell.badge", title: "Notificaciones de Actividad", color: .orange)
                }
            }
            .headerProminence(.increased)
            
            Section {
                Button(role: .destructive) {
                    resetSettings()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.red)
                        Text("Restablecer configuración")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func resetSettings() {
        notificationsEnabled = true
        soundEnabled = true
        vibrationEnabled = true
        notificationPreview = .partial
        quietHoursEnabled = false
    }
}

struct EmergencyAlertsView: View {
    @AppStorage("criticalAlerts") private var criticalAlerts = true
    @AppStorage("policeAlerts") private var policeAlerts = true
    @AppStorage("medicalAlerts") private var medicalAlerts = true
    @AppStorage("fireAlerts") private var fireAlerts = true
    @AppStorage("naturalDisasterAlerts") private var naturalDisasterAlerts = true
    
    var body: some View {
        Form {
            Section(header: Text("ALERTAS DE EMERGENCIA").font(.caption)) {
                Toggle("Alertas críticas", isOn: $criticalAlerts)
                    .tint(.red)
                
                Toggle("Alertas de policía", isOn: $policeAlerts)
                    .tint(.blue)
                
                Toggle("Alertas médicas", isOn: $medicalAlerts)
                    .tint(.green)
                
                Toggle("Alertas de incendios", isOn: $fireAlerts)
                    .tint(.orange)
                
                Toggle("Alertas de desastres naturales", isOn: $naturalDisasterAlerts)
                    .tint(.purple)
                
                InfoText("Estas alertas siempre tendrán prioridad y pueden aparecer incluso con el modo silencioso activado")
            }
            .headerProminence(.increased)
        }
        .navigationTitle("Alertas de Emergencia")
    }
}

struct CommunityAlertsView: View {
    @AppStorage("eventsAlerts") private var eventsAlerts = true
    @AppStorage("meetingsAlerts") private var meetingsAlerts = true
    @AppStorage("generalAlerts") private var generalAlerts = true
    @AppStorage("neighborhoodNews") private var neighborhoodNews = true
    @AppStorage("safetyTips") private var safetyTips = true
    
    var body: some View {
        Form {
            Section(header: Text("ALERTAS COMUNITARIAS").font(.caption)) {
                Toggle("Eventos vecinales", isOn: $eventsAlerts)
                    .tint(.green)
                
                Toggle("Reuniones comunitarias", isOn: $meetingsAlerts)
                    .tint(.green)
                
                Toggle("Anuncios generales", isOn: $generalAlerts)
                    .tint(.green)
                
                Toggle("Noticias del barrio", isOn: $neighborhoodNews)
                    .tint(.green)
                
                Toggle("Consejos de seguridad", isOn: $safetyTips)
                    .tint(.green)
            }
            .headerProminence(.increased)
        }
        .navigationTitle("Alertas Comunitarias")
    }
}

struct ActivityNotificationsView: View {
    @AppStorage("reportUpdates") private var reportUpdates = true
    @AppStorage("newNeighbors") private var newNeighbors = true
    @AppStorage("responseNotifications") private var responseNotifications = true
    @AppStorage("appUpdates") private var appUpdates = true
    
    var body: some View {
        Form {
            Section(header: Text("NOTIFICACIONES DE ACTIVIDAD").font(.caption)) {
                Toggle("Actualizaciones de mis reportes", isOn: $reportUpdates)
                    .tint(.blue)
                
                Toggle("Nuevos vecinos en el área", isOn: $newNeighbors)
                    .tint(.blue)
                
                Toggle("Respuestas a mis publicaciones", isOn: $responseNotifications)
                    .tint(.blue)
                
                Toggle("Actualizaciones de la aplicación", isOn: $appUpdates)
                    .tint(.blue)
            }
            .headerProminence(.increased)
        }
        .navigationTitle("Notificaciones")
    }
}
