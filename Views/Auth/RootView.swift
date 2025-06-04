//
//  RootView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationView {
            if authViewModel.isAuthenticated {
                HomeFeedView()
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
