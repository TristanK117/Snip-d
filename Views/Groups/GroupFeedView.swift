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
    @StateObject private var groupsViewModel = GroupsViewModel()
    @State private var showingAddMembers = false
    @State private var showingGroupInfo = false

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
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddMembers = true }) {
                        Label("Add Members", systemImage: "person.badge.plus")
                    }
                    
                    Button(action: { showingGroupInfo = true }) {
                        Label("Group Info", systemImage: "info.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadSnipes(groupId: group.id)
            }
        }
        .sheet(isPresented: $showingAddMembers) {
            AddMembersView(group: group, groupsViewModel: groupsViewModel)
        }
        .sheet(isPresented: $showingGroupInfo) {
            GroupInfoView(group: group, groupsViewModel: groupsViewModel)
        }
    }
}
