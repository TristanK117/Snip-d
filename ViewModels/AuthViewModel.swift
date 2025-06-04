//
//  AuthViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    func login(email: String, password: String) async {
        do {
            let _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(email: String, password: String) async {
        do {
            let _ = try await Auth.auth().createUser(withEmail: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
