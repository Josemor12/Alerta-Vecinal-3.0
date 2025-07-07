//
//  PrivacyView.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/25/25.
//

import SwiftUI

struct PrivacyView: View {
    @AppStorage("shareLocation") private var shareLocation = false
    @AppStorage("showInMap") private var showInMap = false
    @AppStorage("contactVisibility") private var contactVisibility = false
    @AppStorage("analyticsEnabled") private var analyticsEnabled = true
    @AppStorage("dataSharing") private var dataSharing = false
    
    var body: some View {
        Form {
            Section(header: Text("CONFIGURACIÓN DE PRIVACIDAD").font(.caption)) {
                Toggle("Compartir ubicación", isOn: $shareLocation)
                    .tint(.blue)
                
                if shareLocation {
                    Toggle("Mostrar en el mapa comunitario", isOn: $showInMap)
                        .tint(.blue)
                    
                    InfoText("Tu ubicación aproximada será visible para vecinos en un radio de 500 metros")
                }
                
                Toggle("Mostrar mi contacto a vecinos", isOn: $contactVisibility)
                    .tint(.blue)
                
                Toggle("Compartir datos anónimos para mejorar la app", isOn: $analyticsEnabled)
                    .tint(.blue)
                
                Toggle("Permitir compartir datos con autoridades", isOn: $dataSharing)
                    .tint(.blue)
                    .disabled(!shareLocation)
            }
            .headerProminence(.increased)
            
            Section {
                NavigationLink {
                    VisibleDataView()
                } label: {
                    SettingsRow(icon: "eye", title: "Administrar información visible", color: .blue)
                }
            } header: {
                Text("DATOS PERSONALES").font(.caption)
            }
            
            Section {
                Button(action: exportData) {
                    SettingsRow(icon: "square.and.arrow.up", title: "Exportar mis datos", color: .gray)
                }
                
                NavigationLink {
                    DataRetentionView()
                } label: {
                    SettingsRow(icon: "clock.arrow.circlepath", title: "Configurar retención de datos", color: .gray)
                }
            } header: {
                Text("GESTIÓN DE DATOS").font(.caption)
            }
            
            Section {
                Button(role: .destructive) {
                    deleteAccount()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Eliminar mi cuenta")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Privacidad")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func exportData() {

    }
    
    private func deleteAccount() {

    }
}

struct VisibleDataView: View {
    @AppStorage("showName") private var showName = true
    @AppStorage("showAddress") private var showAddress = false
    @AppStorage("showPhone") private var showPhone = false
    @AppStorage("showNeighborhood") private var showNeighborhood = true
    
    var body: some View {
        Form {
            Section(header: Text("INFORMACIÓN PERSONAL VISIBLE").font(.caption)) {
                Toggle("Mostrar mi nombre", isOn: $showName)
                    .tint(.blue)
                
                Toggle("Mostrar mi dirección", isOn: $showAddress)
                    .tint(.blue)
                
                Toggle("Mostrar mi teléfono", isOn: $showPhone)
                    .tint(.blue)
                
                Toggle("Mostrar mi barrio/comunidad", isOn: $showNeighborhood)
                    .tint(.blue)
            }
            .headerProminence(.increased)
            
            Section {
                InfoText("Esta configuración afecta cómo te ven otros vecinos en la comunidad")
            }
        }
        .navigationTitle("Información Visible")
    }
}

struct DataRetentionView: View {
    @AppStorage("dataRetentionPeriod") private var retentionPeriod = 30
    
    var body: some View {
        Form {
            Section(header: Text("RETENCIÓN DE DATOS").font(.caption)) {
                Picker("Conservar mis datos por", selection: $retentionPeriod) {
                    Text("1 mes").tag(30)
                    Text("3 meses").tag(90)
                    Text("6 meses").tag(180)
                    Text("1 año").tag(365)
                    Text("Indefinidamente").tag(0)
                }
                .pickerStyle(.navigationLink)
                
                InfoText("Los reportes e información se eliminarán automáticamente después del período seleccionado")
            }
            .headerProminence(.increased)
        }
        .navigationTitle("Retención de Datos")
    }
}

struct InfoText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.vertical, 4)
    }
}
