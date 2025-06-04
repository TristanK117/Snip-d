//
//  GroupFeedView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/4/25.
//

import SwiftUI

struct GroupFeedView: View {
    let group: SnipGroup
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        List(viewModel.snipes) { snipe in
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: snipe.imageURL)) { phase in
                    if let image = phase.image {
                        image.resizable()
                             .scaledToFill()
                             .frame(height: 200)
                             .clipped()
                    } else if phase.error != nil {
                        Text("Error loading image")
                    } else {
                        ProgressView()
                    }
                }

                Text("📸 \(snipe.postedBy)").font(.subheadline)
                Text("Group: \(snipe.groupName)").font(.footnote).foregroundColor(.secondary)
                Text(snipe.timestamp, style: .relative).font(.caption).foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle(group.name)
        .onAppear {
            Task {
                await viewModel.loadSnipes(groupId: group.id ?? "")
            }
        }
    }
}
