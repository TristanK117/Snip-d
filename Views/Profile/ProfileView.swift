//
//  ProfileView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if let email = viewModel.userEmail {
                    Text("📧 \(email)")
                        .font(.title3)
                }

                List(viewModel.taggedSnipes) { snipe in
                    VStack(alignment: .leading) {
                        Text("📸 \(snipe.postedBy)")
                            .font(.headline)
                        Text("Group: \(snipe.groupName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(snipe.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                Button("Logout") {
                    viewModel.logout()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.fetchTaggedSnipes()
            }
        }
    }
}
