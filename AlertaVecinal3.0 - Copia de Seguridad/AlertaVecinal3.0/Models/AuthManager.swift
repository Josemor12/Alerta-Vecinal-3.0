//
//  AuthManager.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/22/25.
//

import Foundation

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    
    func login(phone: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let success = !phone.isEmpty && !password.isEmpty
            self.isAuthenticated = success
            completion(success)
        }
    }
    
    func register(
        username: String,
        email: String,
        password: String,
        profileImage: Data? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let isValid = !username.isEmpty && !email.isEmpty && !password.isEmpty
            self.isAuthenticated = isValid
            
            if isValid {
                if let imageData = profileImage {
                    print("Foto de perfil recibida (\(imageData.count) bytes)")
                } else {
                    print("Registro sin foto de perfil")
                }
            }
            
            completion(isValid)
        }
    }
    
    func logout() {
        isAuthenticated = false
    }
}
