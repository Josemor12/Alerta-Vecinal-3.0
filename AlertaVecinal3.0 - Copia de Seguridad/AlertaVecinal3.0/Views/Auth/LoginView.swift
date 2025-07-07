//
//  LoginView.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/22/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var mostrarContraseña = false
    @State private var recordarUsuario = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var navegarARegistro = false
    @State private var navegarADashboard = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 2) {
                VStack {
                    
                    Image("logo")
                        .resizable()
                        .frame(width: 250, height: 190)
                        .foregroundColor(.blue)
                    
                    Text("Alerta Vecinal 3.0")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                VStack {
                    Text("¡Tu seguridad, nuestra prioridad!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom, 15)

                    Text("Inicia sesión en tu cuenta")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }
                

                VStack(spacing: 15) {
                    TextField("Usuario o Email", text: $username)
                        .font(.callout)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal)
                    
                    HStack {
                        if mostrarContraseña {
                            TextField("Contraseña", text: $password)
                                .font(.body)
                        } else {
                            SecureField("Contraseña", text: $password)
                                .font(.body)
                        }
                        
                        Button(action: {
                            mostrarContraseña.toggle()
                        }) {
                            Image(systemName: mostrarContraseña ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    HStack {
                        Toggle("Recordar usuario", isOn: $recordarUsuario)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .font(.footnote)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        Button("¿Olvidaste tu contraseña?") {

                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                NavigationLink(destination: MainTabView(), isActive: $navegarADashboard) {
                    Button(action: {
                        loginUser()
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Iniciar Sesión")
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isLoading)
                }
                .padding(.vertical)
                
                HStack {
                    VStack { Divider() }
                    Text("O Iniciar sesión con")
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
                    Text("¿No tienes una cuenta?")
                    NavigationLink(destination: RegistrationView(), isActive: $navegarARegistro) {
                        Text("Regístrate aquí")
                            .foregroundColor(.blue)
                    }
                }
                .font(.footnote)
                .padding(.top)
                
                Spacer()
            }
            .padding(30)
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loginUser() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor ingresa tu usuario y contraseña"
            showError = true
            return
        }
        
        isLoading = true
        authManager.login(phone: username, password: password) { success in
            isLoading = false
            if success {
                navegarADashboard = true
                if recordarUsuario {

                }
            } else {
                errorMessage = "Usuario o contraseña incorrectos"
                showError = true
            }
        }
    }
}
