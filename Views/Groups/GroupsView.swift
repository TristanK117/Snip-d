//
//  GroupsView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct GroupsView: View {
    @StateObject private var viewModel = GroupsViewModel()
    @State private var selectedGroupForAddingMembers: SnipGroup?

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Groups...")
                        .padding()
                } else if viewModel.groups.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No groups yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Create or join a group to start sharing!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button("Create Your First Group") {
                            viewModel.showingGroupCreation = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List(viewModel.groups, id: \.id) { group in
                        NavigationLink(destination: GroupFeedView(group: group)) {
                            GroupRowView(group: group)
                        }
                        .contextMenu {
                            Button(action: {
                                selectedGroupForAddingMembers = group
                            }) {
                                Label("Add Members", systemImage: "person.badge.plus")
                            }
                            
                            Button(action: {
                                // TODO: Group settings
                            }) {
                                Label("Group Settings", systemImage: "gear")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingGroupCreation = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingGroupCreation) {
                CreateGroupView(viewModel: viewModel)
            }
            .sheet(item: $selectedGroupForAddingMembers) { group in
                AddMembersView(group: group, groupsViewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.fetchGroups()
                }
            }
        }
    }
}


struct GroupRowView: View {
    let group: SnipGroup
    
    var body: some View {
        HStack(spacing: 12) {

            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(group.name.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(group.members.count) member\(group.members.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
