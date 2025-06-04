//
//  RegisterView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistered = false

    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button("Register") {
                    Task {
                        await authViewModel.register(email: email, password: password, name: name)
                        isRegistered = authViewModel.isLoggedIn
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationDestination(isPresented: $isRegistered) {
                MainTabView(authViewModel: authViewModel)
            }
        }
    }
}
