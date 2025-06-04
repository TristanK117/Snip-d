//
//  RegisterView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Create an Account")
                .font(.title2)
                .bold()

            TextField("Full Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(isLoading ? "Registering..." : "Register") {
                Task {
                    isLoading = true
                    await registerUser()
                    isLoading = false
                }
            }
            .disabled(name.isEmpty || email.isEmpty || password.count < 6)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func registerUser() async {
        // Validate inputs
        guard Validators.isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return
        }

        guard Validators.isValidPassword(password) else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }

        guard !name.trimmed.isEmpty else {
            errorMessage = "Name cannot be empty."
            return
        }

        // Register with Firebase Auth
        await authViewModel.register(email: email, password: password)

        if let uid = Auth.auth().currentUser?.uid {
            do {
                let userData: [String: Any] = [
                    "uid": uid,
                    "name": name.trimmed,
                    "email": email.trimmed
                ]
                try await Firestore.firestore().collection("users").document(uid).setData(userData)
            } catch {
                errorMessage = "Failed to save user data: \(error.localizedDescription)"
            }
        }

        if let error = authViewModel.errorMessage {
            self.errorMessage = error
        }
    }
}
