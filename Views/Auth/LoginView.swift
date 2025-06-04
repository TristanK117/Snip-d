//
//  LoginView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Button("Login") {
                Task {
                    await authViewModel.login(email: email, password: password)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
