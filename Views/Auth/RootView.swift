//
//  RootView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showingRegister = false

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView(authViewModel: authViewModel)
            } else {
                NavigationStack {
                    VStack {
                        LoginView(authViewModel: authViewModel)

                        Button("Don't have an account? Register here") {
                            showingRegister = true
                        }
                        .padding(.top, 12)
                        .navigationDestination(isPresented: $showingRegister) {
                            RegisterView()
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            authViewModel.fetchCurrentUser()
        }
    }
}
