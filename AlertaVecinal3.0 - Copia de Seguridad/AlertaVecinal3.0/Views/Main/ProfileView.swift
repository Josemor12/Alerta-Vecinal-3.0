//
//  ProfileView.swift
//  AlertaVecinal3.0
//

import SwiftUI

// MARK: - Vista Principal de Perfil
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var user: User = User.mockUser()
    @State private var isLoading = true
    @State private var showEditProfile = false
    @State private var showTerms = false
    @State private var showPrivacyPolicy = false
    @State private var showDeleteConfirmation = false
    @State private var loadAttempted = false
    
    var body: some View {
        NavigationStack {
            if isLoading && !loadAttempted {
                ProgressView("Cargando perfil...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear { loadUserData() }
            } else {
                List {
                    userInfoSection
                    activitySection
                    settingsSection
                    legalInfoSection
                    accountSection
                }
                .navigationTitle("Mi Perfil")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: shareProfile) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .sheet(isPresented: $showEditProfile) {
                    EditProfileView(user: $user)
                }
                .sheet(isPresented: $showTerms) {
                    LegalDocumentView(type: .terms)
                }
                .sheet(isPresented: $showPrivacyPolicy) {
                    LegalDocumentView(type: .privacy)
                }
                .alert("Eliminar cuenta", isPresented: $showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Eliminar", role: .destructive) {
                        deleteAccount()
                    }
                } message: {
                    Text("¿Estás seguro que deseas eliminar tu cuenta permanentemente? Esta acción no se puede deshacer.")
                }
            }
        }
    }
    
    // MARK: - Secciones de la Vista
    private var userInfoSection: some View {
        Section {
            HStack(spacing: 15) {
                ProfilePictureView(imageUrl: user.profileImageUrl, size: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName)
                        .font(.title3.bold())
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Miembro desde: \(user.joinDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let neighborhood = user.neighborhood {
                        Text(neighborhood)
                            .font(.caption)
                            .padding(4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Button(action: { showEditProfile = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var activitySection: some View {
        Section("Actividad") {
            HStack {
                StatView(value: "1", label: "Reportes")
                Divider()
                StatView(value: "5", label: "Alertas")
                Divider()
                StatView(value: "24", label: "Vecinos")
            }
            .frame(height: 60)
        }
    }
    
    private var settingsSection: some View {
        Section("Configuración") {
            NavigationLink {
                NotificationsView()
            } label: {
                SettingsRow(icon: "bell.badge", title: "Notificaciones", color: .orange)
            }
            
            NavigationLink {
                PrivacyView()
            } label: {
                SettingsRow(icon: "lock", title: "Privacidad", color: .blue)
            }
            
            NavigationLink {
                EmergencyContactsView()
            } label: {
                SettingsRow(icon: "person.2", title: "Contactos de emergencia", color: .green)
            }
            
            NavigationLink {
                AppSettingsView()
            } label: {
                SettingsRow(icon: "gearshape", title: "Ajustes de la app", color: .gray)
            }
        }
    }
    
    private var legalInfoSection: some View {
        Section("Información") {
            Button {
                showTerms = true
            } label: {
                SettingsRow(icon: "doc.text", title: "Términos y condiciones", color: .secondary)
            }
            
            Button {
                showPrivacyPolicy = true
            } label: {
                SettingsRow(icon: "hand.raised", title: "Política de privacidad", color: .secondary)
            }
        }
    }
    
    private var accountSection: some View {
        Section {
            Button("Cerrar Sesión", role: .destructive) {
                authManager.logout()
            }
            
            Button("Eliminar cuenta", role: .destructive) {
                showDeleteConfirmation = true
            }
        }
    }
    
    // MARK: - Funciones
    private func loadUserData() {
        guard !loadAttempted else { return }
        loadAttempted = true
        
        // Simulación de carga (reemplazar con llamada real a API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.user = User.mockUser()
            self.isLoading = false
        }
    }
    
    private func shareProfile() {
        // Lógica para compartir perfil
    }
    
    private func deleteAccount() {
        // Lógica para eliminar cuenta
    }
}

// MARK: - Vistas Complementarias
struct EditProfileView: View {
    @Binding var user: User
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información personal") {
                    TextField("Nombre completo", text: $user.fullName)
                    TextField("Correo electrónico", text: $user.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Teléfono", text: Binding(
                        get: { user.phone ?? "" },
                        set: { user.phone = $0.isEmpty ? nil : $0 }
                    ))
                    .keyboardType(.phonePad)
                }
                
                Section("Ubicación") {
                    TextField("Dirección", text: Binding(
                        get: { user.address ?? "" },
                        set: { user.address = $0.isEmpty ? nil : $0 }
                    ))
                    TextField("Barrio/Comunidad", text: Binding(
                        get: { user.neighborhood ?? "" },
                        set: { user.neighborhood = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section("Foto de perfil") {
                    ProfilePictureEditor(image: $selectedImage)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Guardar") {
                        // Guardar cambios
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EmergencyContactsView: View {
    @State private var contacts: [EmergencyContact] = [
        EmergencyContact(name: "Policía Nacional", phone: "104", relation: "Emergencias"),
        EmergencyContact(name: "Bomberos", phone: "103", relation: "Emergencias"),
        EmergencyContact(name: "Familiares", phone: "+507 6123-4567", relation: "Familiar")
    ]
    
    @State private var showingAddContact = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(contacts) { contact in
                    ContactRow(contact: contact)
                }
                .onDelete(perform: deleteContact)
                
                Button {
                    showingAddContact = true
                } label: {
                    Label("Añadir contacto", systemImage: "plus")
                }
            }
            .navigationTitle("Contactos de Emergencia")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactView(contacts: $contacts)
            }
        }
    }
    
    private func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
}

struct AppSettingsView: View {
    @AppStorage("appTheme") private var appTheme = "system"
    @AppStorage("mapStyle") private var mapStyle = "standard"
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    
    var body: some View {
        Form {
            Section("Apariencia") {
                Picker("Tema", selection: $appTheme) {
                    Text("Automático").tag("system")
                    Text("Claro").tag("light")
                    Text("Oscuro").tag("dark")
                }
                
                Picker("Estilo del Mapa", selection: $mapStyle) {
                    Text("Estándar").tag("standard")
                    Text("Satélite").tag("satellite")
                    Text("Híbrido").tag("hybrid")
                }
            }
            
            Section("Notificaciones") {
                Toggle("Notificaciones activas", isOn: $notificationEnabled)
            }
            
            Section {
                Button("Restablecer configuración") {
                    appTheme = "system"
                    mapStyle = "standard"
                    notificationEnabled = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Ajustes de la App")
    }
}

// MARK: - Componentes Reutilizables
struct ProfilePictureView: View {
    let imageUrl: String?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let imageUrl = imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.blue.opacity(0.3))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
        .shadow(radius: 3)
    }
}

struct ProfilePictureEditor: View {
    @Binding var image: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.3))
            }
            
            Button(image == nil ? "Seleccionar foto" : "Cambiar foto") {
                showImagePicker = true
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .symbolVariant(.fill)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}

struct ContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                Text(contact.relation)
                    .font(.caption)
            }
            Spacer()
            Button {
                callNumber(phoneNumber: contact.phone)
            } label: {
                Image(systemName: "phone")
                    .foregroundColor(.green)
            }
        }
    }
    
    private func callNumber(phoneNumber: String) {
        let cleanedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(cleanedNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

struct AddContactView: View {
    @Binding var contacts: [EmergencyContact]
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var phone = ""
    @State private var relation = "Familiar"
    private let relations = ["Familiar", "Vecino", "Médico", "Emergencias", "Otro"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del contacto") {
                    TextField("Nombre", text: $name)
                    TextField("Teléfono", text: $phone)
                        .keyboardType(.phonePad)
                    Picker("Relación", selection: $relation) {
                        ForEach(relations, id: \.self) { rel in
                            Text(rel)
                        }
                    }
                }
            }
            .navigationTitle("Nuevo Contacto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Guardar") {
                        let newContact = EmergencyContact(
                            name: name,
                            phone: phone,
                            relation: relation
                        )
                        contacts.append(newContact)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}

struct LegalDocumentView: View {
    enum DocumentType {
        case terms, privacy
        
        var title: String {
            switch self {
            case .terms: return "Términos y Condiciones"
            case .privacy: return "Política de Privacidad"
            }
        }
        
        var sections: [DocumentSection] {
            switch self {
            case .terms:
                return [
                    DocumentSection(title: "1. Aceptación de los Términos",
                                  content: "Al acceder y utilizar la aplicación AlertaVecinal, usted acepta cumplir con estos términos y condiciones, así como con nuestra Política de Privacidad. Si no está de acuerdo con alguno de estos términos, no debe utilizar nuestra aplicación."),
                    
                    DocumentSection(title: "2. Uso Apropiado",
                                  content: "La aplicación está diseñada exclusivamente para reportar incidentes y mantener informada a la comunidad. Queda estrictamente prohibido:\n\n• Usar la aplicación para fines ilegales o fraudulentos\n• Publicar contenido difamatorio, obsceno o ofensivo\n• Compartir información falsa o engañosa\n• Vulnerar derechos de propiedad intelectual\n• Realizar actividades que puedan dañar la aplicación o su infraestructura"),
                    
                    DocumentSection(title: "3. Responsabilidades del Usuario",
                                  content: "Como usuario de AlertaVecinal, usted es responsable de:\n\n• La veracidad de la información que comparte\n• Mantener la confidencialidad de su cuenta y contraseña\n• Respetar la privacidad de otros usuarios\n• Usar la aplicación de acuerdo con las leyes locales\n• Reportar cualquier uso indebido que observe"),
                    
                    DocumentSection(title: "4. Modificaciones",
                                  content: "Nos reservamos el derecho de modificar estos términos en cualquier momento. Las versiones actualizadas se publicarán en la aplicación. El uso continuado de la aplicación después de dichas modificaciones constituirá su aceptación de los nuevos términos."),
                    
                    DocumentSection(title: "5. Limitación de Responsabilidad",
                                  content: "AlertaVecinal no será responsable por:\n\n• Daños directos o indirectos derivados del uso de la aplicación\n• Exactitud de la información proporcionada por otros usuarios\n• Interrupciones en el servicio por causas fuera de nuestro control\n• Contenido publicado por terceros"),
                    
                    DocumentSection(title: "6. Ley Aplicable",
                                  content: "Estos términos se rigen por las leyes de la República de Panamá. Cualquier disputa relacionada con estos términos o con el uso de la aplicación estará sujeta a la jurisdicción exclusiva de los tribunales competentes de Panamá.")
                ]
                
            case .privacy:
                return [
                    DocumentSection(title: "1. Información que Recopilamos",
                                  content: "Para proporcionar nuestros servicios, recopilamos:\n\n• Datos personales (nombre, email, teléfono)\n• Datos de ubicación (cuando reportas un incidente)\n• Datos de uso (cómo interactúas con la app)\n• Datos del dispositivo (modelo, sistema operativo)\n• Información que voluntariamente compartes (reportes, fotos)"),
                    
                    DocumentSection(title: "2. Uso de la Información",
                                  content: "Utilizamos tu información para:\n\n• Proporcionar y mejorar nuestros servicios\n• Mantener segura a la comunidad\n• Personalizar tu experiencia\n• Comunicarnos contigo\n• Cumplir con obligaciones legales\n• Prevenir fraudes y abusos"),
                    
                    DocumentSection(title: "3. Compartir Información",
                                  content: "Podemos compartir información con:\n\n• Autoridades competentes (en casos de emergencia)\n• Proveedores de servicios (para operar la aplicación)\n• Otros usuarios (solo información relevante para reportes)\n\nNunca vendemos tus datos personales a terceros."),
                    
                    DocumentSection(title: "4. Seguridad de Datos",
                                  content: "Implementamos medidas de seguridad técnicas y organizativas:\n\n• Encriptación de datos sensibles\n• Acceso restringido al personal autorizado\n• Revisiones periódicas de seguridad\n• Protocolos para manejo de incidentes"),
                    
                    DocumentSection(title: "5. Tus Derechos",
                                  content: "Tienes derecho a:\n\n• Acceder a tus datos personales\n• Solicitar corrección de información incorrecta\n• Pedir eliminación de tus datos\n• Oponerte al procesamiento de tus datos\n• Solicitar limitación del tratamiento\n• Portabilidad de datos"),
                    
                    DocumentSection(title: "6. Cambios a esta Política",
                                  content: "Podemos actualizar esta política ocasionalmente. Te notificaremos sobre cambios significativos a través de la aplicación o por correo electrónico. El uso continuado de la aplicación después de estos cambios constituirá tu aceptación de la política revisada.")
                ]
            }
        }
    }
    
    let type: DocumentType
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(type.title)
                        .font(.title.bold())
                        .padding(.bottom, 10)
                    
                    ForEach(type.sections.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(type.sections[index].title)
                                .font(.headline)
                            Text(type.sections[index].content)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    struct DocumentSection {
        let title: String
        let content: String
    }
}

// MARK: - Modelos de Datos
struct User {
    var id: String
    var fullName: String
    var email: String
    var phone: String?
    var address: String?
    var neighborhood: String?
    var profileImageUrl: String?
    let joinDate: Date
    
    static func mockUser() -> User {
        User(
            id: "user123",
            fullName: "José Moreno",
            email: "josemoreno@gmail.com",
            phone: "+507 6123-4567",
            address: "Calle A, Urb. Mirador",
            neighborhood: "Rio Hato",
            profileImageUrl: nil,
            joinDate: Date.now.addingTimeInterval(-90*24*60*60)
        )
    }
}

struct EmergencyContact: Identifiable {
    let id = UUID()
    let name: String
    let phone: String
    let relation: String
}

// MARK: - Image Picker (requiere UIKit)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
