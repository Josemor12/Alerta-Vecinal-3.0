//
//  CommunityChatView.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/30/25.
//
//

import SwiftUI

struct CommunityChatView: View {
    @State private var messages: [ChatMessage] = ChatMessage.mockData()
    @State private var newMessage: String = ""
    @State private var selectedChannel: ChatChannel = .general
    @State private var showChannelSelector = false
    @State private var showFilters = false
    @State private var filters = ChatFilters()
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    private var filteredMessages: [ChatMessage] {
        var result = messages.filter { $0.channel == selectedChannel }
        
        if filters.hideOldMessages {
            result = result.filter { $0.timestamp > Calendar.current.date(byAdding: .hour, value: -12, to: Date())! }
        }
        
        if filters.hideNonUrgent {
            result = result.filter { $0.priority >= .normal }
        }
        
        if !filters.showAllTypes {
            result = result.filter { $0.type == filters.selectedType }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showChannelSelector.toggle()
                } label: {
                    HStack {
                        Image(systemName: selectedChannel.icon)
                            .foregroundColor(selectedChannel.color)
                        Text(selectedChannel.rawValue)
                            .font(.subheadline.bold())
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 2)
                }
                
                Spacer()
                
                Button {
                    showFilters.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolVariant(filters.isActive ? .fill : .none)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredMessages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                                .contextMenu {
                                    Button {
                                        reportMessage(message)
                                    } label: {
                                        Label("Reportar", systemImage: "exclamationmark.bubble")
                                    }
                                    
                                    Button {
                                        muteUser(message.sender)
                                    } label: {
                                        Label("Silenciar usuario", systemImage: "speaker.slash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                }
                .onChange(of: filteredMessages) { _ in
                    scrollToBottom()
                }
            }
            
            // Message input
            HStack {
                TextField("Escribe un mensaje...", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .padding(8)
                        .background(newMessage.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(newMessage.isEmpty)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
        }
        .navigationTitle("Chat Vecinal")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showChannelSelector) {
            ChannelSelectorView(selectedChannel: $selectedChannel)
        }
        .sheet(isPresented: $showFilters) {
            ChatFiltersView(filters: $filters)
        }
        .onChange(of: selectedChannel) { _ in
            scrollToBottom()
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let message = ChatMessage(
            id: UUID().uuidString,
            content: newMessage,
            sender: "Usuario Actual",
            timestamp: Date(),
            channel: selectedChannel,
            type: .general,
            priority: .normal
        )
        
        messages.append(message)
        newMessage = ""
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            withAnimation {
                scrollProxy?.scrollTo(filteredMessages.last?.id, anchor: .bottom)
            }
        }
    }
    
    private func reportMessage(_ message: ChatMessage) {
   
    }
    
    private func muteUser(_ user: String) {

    }
}

// MARK: - Components

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(message.sender)
                    .font(.caption.bold())
                    .foregroundColor(message.channel.color)
                
                Spacer()
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(message.content)
                .font(.body)
                .padding(8)
                .background(message.isOutgoing ? Color.blue.opacity(0.1) : Color(.secondarySystemBackground))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if message.priority != .normal || message.type != .general {
                HStack(spacing: 4) {
                    if message.priority != .normal {
                        Image(systemName: message.priority.icon)
                            .font(.caption2)
                            .foregroundColor(message.priority.color)
                        Text(message.priority.rawValue)
                            .font(.caption2)
                            .foregroundColor(message.priority.color)
                    }
                    
                    if message.type != .general {
                        Image(systemName: message.type.icon)
                            .font(.caption2)
                            .foregroundColor(message.type.color)
                        Text(message.type.rawValue)
                            .font(.caption2)
                            .foregroundColor(message.type.color)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

struct ChannelSelectorView: View {
    @Binding var selectedChannel: ChatChannel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(ChatChannel.allCases, id: \.self) { channel in
                HStack {
                    Image(systemName: channel.icon)
                        .foregroundColor(channel.color)
                        .frame(width: 30)
                    
                    Text(channel.rawValue)
                    
                    Spacer()
                    
                    if channel == selectedChannel {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedChannel = channel
                    dismiss()
                }
            }
            .navigationTitle("Seleccionar Canal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ChatFiltersView: View {
    @Binding var filters: ChatFilters
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Filtrar por tipo") {
                    Toggle("Mostrar todos los tipos", isOn: $filters.showAllTypes)
                    
                    if !filters.showAllTypes {
                        Picker("Tipo de mensaje", selection: $filters.selectedType) {
                            ForEach(ChatMessageType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon)
                                    .foregroundColor(type.color)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }
                
                Section("Opciones avanzadas") {
                    Toggle("Ocultar mensajes antiguos (>12 hrs)", isOn: $filters.hideOldMessages)
                    Toggle("Ocultar mensajes no urgentes", isOn: $filters.hideNonUrgent)
                }
            }
            .navigationTitle("Filtros del Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Aplicar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Data Models

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let content: String
    let sender: String
    let timestamp: Date
    let channel: ChatChannel
    let type: ChatMessageType
    let priority: MessagePriority
    
    var isOutgoing: Bool {
        sender == "Usuario Actual"
    }
    
    static func mockData() -> [ChatMessage] {
        [
            ChatMessage(
                id: "1",
                content: "¡Hola vecinos! ¿Alguien vio el camión de basura hoy?",
                sender: "María González",
                timestamp: Date().addingTimeInterval(-3600),
                channel: .general,
                type: .question,
                priority: .normal
            ),
            ChatMessage(
                id: "2",
                content: "Hay un perro perdido en la calle principal, parece asustado",
                sender: "Carlos Pérez",
                timestamp: Date().addingTimeInterval(-1800),
                channel: .animals,
                type: .alert,
                priority: .high
            )
        ]
    }
}

enum ChatChannel: String, CaseIterable {
    case general = "General"
    case emergencies = "Emergencias"
    case announcements = "Anuncios"
    case security = "Seguridad"
    case animals = "Animales"
    case events = "Eventos"
    
    var icon: String {
        switch self {
        case .general: return "bubble.left.and.bubble.right"
        case .emergencies: return "exclamationmark.triangle"
        case .announcements: return "megaphone"
        case .security: return "shield"
        case .animals: return "pawprint"
        case .events: return "calendar"
        }
    }
    
    var color: Color {
        switch self {
        case .general: return .gray
        case .emergencies: return .red
        case .announcements: return .blue
        case .security: return .purple
        case .animals: return .orange
        case .events: return .green
        }
    }
}

enum ChatMessageType: String, CaseIterable {
    case general = "General"
    case question = "Pregunta"
    case alert = "Alerta"
    case announcement = "Anuncio"
    case help = "Ayuda"
    
    var icon: String {
        switch self {
        case .general: return "text.bubble"
        case .question: return "questionmark.bubble"
        case .alert: return "exclamationmark.bubble"
        case .announcement: return "megaphone"
        case .help: return "hand.raised"
        }
    }
    
    var color: Color {
        switch self {
        case .general: return .gray
        case .question: return .blue
        case .alert: return .red
        case .announcement: return .green
        case .help: return .orange
        }
    }
}

enum MessagePriority: String, Comparable {
    case low = "Baja"
    case normal = "Normal"
    case high = "Alta"
    case urgent = "Urgente"
    
    var icon: String {
        switch self {
        case .low: return "arrow.down"
        case .normal: return "minus"
        case .high: return "arrow.up"
        case .urgent: return "exclamationmark"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .normal: return .gray
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    static func < (lhs: MessagePriority, rhs: MessagePriority) -> Bool {
        let order: [MessagePriority] = [.low, .normal, .high, .urgent]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

struct ChatFilters {
    var showAllTypes = true
    var selectedType: ChatMessageType = .general
    var hideOldMessages = false
    var hideNonUrgent = false
    
    var isActive: Bool {
        !showAllTypes || hideOldMessages || hideNonUrgent
    }
}
