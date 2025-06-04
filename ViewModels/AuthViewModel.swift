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
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    @Published var currentUser: User?

    func register(email: String, password: String, name: String) async {
        do {
            try await AuthService.registerUser(email: email, password: password, name: name)
            currentUser = Auth.auth().currentUser
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func login(email: String, password: String) async {
        do {
            try await AuthService.loginUser(email: email, password: password)
            currentUser = Auth.auth().currentUser
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        do {
            try AuthService.logoutUser()
            isLoggedIn = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchCurrentUser() {
        currentUser = AuthService.getCurrentUser()
        isLoggedIn = (currentUser != nil)
    }
}
