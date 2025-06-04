//
//  ProfileView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let email = viewModel.userEmail {
                    Text("📧 \(email)")
                        .font(.title3)
                        .padding(.top)
                }

                List(viewModel.taggedSnipes) { snipe in
                    VStack(alignment: .leading) {
                        Text("📸 \(snipe.postedBy)")
                        Text("Group: \(snipe.groupName)")
                        Text(snipe.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Button("Logout") {
                    viewModel.logout()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.fetchTaggedSnipes()
            }
        }
    }
}
