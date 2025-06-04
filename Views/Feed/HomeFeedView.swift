//
//  HomeFeedView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct HomeFeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.snipes) { snipe in
                VStack(alignment: .leading, spacing: 4) {
                    Text("📸 \(snipe.postedBy)")
                        .font(.headline)
                    Text("Group: \(snipe.groupName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(snipe.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Your Feed")
            .onAppear {
                viewModel.loadSnipes()
            }
        }
    }
}

