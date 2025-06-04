//
//  ProfileView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var viewModel: AuthViewModel

    // Mock snipes user is tagged in
    let mockSnipes = [
        Snipe(photoURL: "snipe1.jpg", postedBy: "Jamie", groupName: "Dorm 2B", timestamp: Date().addingTimeInterval(-3600)),
        Snipe(photoURL: "snipe2.jpg", postedBy: "Nina", groupName: "UW Friends", timestamp: Date().addingTimeInterval(-7200))
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if let user = Auth.auth().currentUser {
                    VStack {
                        Text("📧 \(user.email ?? "Unknown")")
                            .font(.title3)
                        Text("You've been sniped in \(mockSnipes.count) posts")
                            .foregroundColor(.gray)
                    }
                }

                List(mockSnipes) { snipe in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("📸 Posted by \(snipe.postedBy)")
                            .font(.headline)
                        Text("Group: \(snipe.groupName)")
                            .font(.subheadline)
                        Text(snipe.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Button("Logout") {
                    viewModel.logout()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .navigationTitle("Profile")
            .padding()
        }
    }
}
