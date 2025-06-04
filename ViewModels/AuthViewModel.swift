//
//  AuthViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    func login(email: String, password: String) async {
        do {
            let _ = try await withCheckedThrowingContinuation { continuation in
                AuthService.shared.signIn(email: email, password: password) { result in
                    continuation.resume(with: result)
                }
            }
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(email: String, password: String) async {
        do {
            let _ = try await withCheckedThrowingContinuation { continuation in
                AuthService.shared.signUp(email: email, password: password) { result in
                    continuation.resume(with: result)
                }
            }
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        do {
            try AuthService.shared.signOut()
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
