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
                VStack(alignment: .leading) {
                    AsyncImage(url: URL(string: snipe.imageURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                        } else if phase.error != nil {
                            Text("Error loading image")
                        } else {
                            ProgressView()
                        }
                    }

                    Text("📸 \(snipe.postedBy)")
                        .font(.subheadline)

                    Text("Group: \(snipe.groupName)")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Text(snipe.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .listStyle(.plain)
            .navigationTitle("Recent Snipes")
            .onAppear {
                Task {
                    await viewModel.loadAllUserSnipes()
                }
            }
        }
    }
}
