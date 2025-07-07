//
//  RegistrationView.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/22/25.
//

import SwiftUI
import PhotosUI

struct RegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var neighborhood = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var acceptTerms = false
    @State private var acceptDataLaw = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var navigateToDashboard = false
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.leading, 25)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)

                    VStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 230, height: 170)
                            .foregroundColor(.blue)
                        
                        Text("Alerta Vecinal 3.0")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }
                    
                    VStack {
                        Text("¡Tu seguridad, nuestra prioridad!")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Regístrate para comenzar")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    if showSuccess {
                        Text("Registro exitoso!")
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 15) {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text(profileImage == nil ? "Añadir foto de perfil (opcional)" : "Cambiar foto")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    
                    // Formulario
                    VStack(spacing: 15) {
                        Group {
                            RequiredTextField(title: "Nombre completo*", text: $fullName)
                            RequiredTextField(title: "Nombre de usuario*", text: $username)
                                .autocapitalization(.none)
                            RequiredTextField(title: "Correo electrónico*", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            RequiredTextField(title: "Teléfono*", text: $phone)
                                .keyboardType(.phonePad)
                            RequiredTextField(title: "Dirección*", text: $address)
                            RequiredTextField(title: "Barrio/Comunidad*", text: $neighborhood)
                            
                            HStack {
                                if showPassword {
                                    RequiredTextField(title: "Contraseña*", text: $password)
                                } else {
                                    RequiredSecureField(title: "Contraseña*", text: $password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            if showPassword {
                                RequiredTextField(title: "Confirmar contraseña*", text: $confirmPassword)
                            } else {
                                RequiredSecureField(title: "Confirmar contraseña*", text: $confirmPassword)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Acepto los Términos y Condiciones*", isOn: $acceptTerms)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .font(.footnote)
                            
                            Toggle("Acepto la Ley 81 de Protección de Datos (Panamá)*", isOn: $acceptDataLaw)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .font(.footnote)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        registerUser()
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Registrarse")
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(areAllFieldsValid() ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isLoading)
                    .padding(.vertical)

                    HStack {
                        VStack { Divider() }
                        Text("O regístrate con")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize()
                        VStack { Divider() }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Image("google-logo")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {}) {
                            Image("facebook-logo")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "applelogo")
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top)
                    
                    HStack {
                        Text("¿Ya tienes una cuenta?")
                        NavigationLink(destination: LoginView()) {
                            Text("Inicia sesión")
                                .foregroundColor(.blue)
                        }
                    }
                    .font(.footnote)
                    .padding(.top)
                }
                .padding(.horizontal, 30)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToDashboard) {
                MainTabView()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func areAllFieldsValid() -> Bool {
        let basicValidation = !fullName.isEmpty &&
                             !username.isEmpty &&
                             !email.isEmpty &&
                             !phone.isEmpty &&
                             !address.isEmpty &&
                             !neighborhood.isEmpty &&
                             !password.isEmpty &&
                             !confirmPassword.isEmpty &&
                             acceptTerms &&
                             acceptDataLaw
        
        let emailValid = email.isValidEmail()
        let passwordValid = password.count >= 6
        let passwordsMatch = password == confirmPassword
        
        return basicValidation && emailValid && passwordValid && passwordsMatch
    }
    
    private func registerUser() {
        showError = false
        showSuccess = false
        
        let validations: [(Bool, String)] = [
            (!fullName.isEmpty, "El nombre completo es obligatorio"),
            (!username.isEmpty, "El nombre de usuario es obligatorio"),
            (!email.isEmpty, "El correo electrónico es obligatorio"),
            (email.isValidEmail(), "Por favor ingresa un correo electrónico válido"),
            (!phone.isEmpty, "El teléfono es obligatorio"),
            (!address.isEmpty, "La dirección es obligatoria"),
            (!neighborhood.isEmpty, "El barrio/comunidad es obligatorio"),
            (!password.isEmpty, "La contraseña es obligatoria"),
            (password.count >= 6, "La contraseña debe tener al menos 6 caracteres"),
            (!confirmPassword.isEmpty, "Debes confirmar tu contraseña"),
            (password == confirmPassword, "Las contraseñas no coinciden"),
            (acceptTerms, "Debes aceptar los términos y condiciones"),
            (acceptDataLaw, "Debes aceptar la Ley de Protección de Datos")
        ]
        
        for (isValid, error) in validations where !isValid {
            errorMessage = error
            showError = true
            return
        }
        
        isLoading = true
        
        let imageData = profileImage?.jpegData(compressionQuality: 0.7)
        
        authManager.register(
            username: username,
            email: email,
            password: password,
            profileImage: imageData
        ) { success in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        navigateToDashboard = true
                    }
                } else {
                    errorMessage = "Error al registrar. Intenta nuevamente."
                    showError = true
                }
            }
        }
    }
}

struct RequiredTextField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.callout)
        }
    }
}

struct RequiredSecureField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            SecureField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.callout)
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}
