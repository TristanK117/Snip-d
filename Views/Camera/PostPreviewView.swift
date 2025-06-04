//
//  PostPreviewView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import FirebaseAuth

struct PostPreviewView: View {
    let image: UIImage

    @StateObject private var viewModel = PostPreviewViewModel()
    @State private var selectedGroup: SnipGroup?
    @State private var taggedFriends: [SnipUser] = []
    @State private var groups: [SnipGroup] = []
    @State private var friends: [SnipUser] = []
    @State private var isPosting = false
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)

                // Group Picker
                Picker("Select Group", selection: $selectedGroup) {
                    ForEach(groups, id: \.self) { group in
                        Text(group.name).tag(Optional(group))
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedGroup) { newGroup in
                    loadUsersForSelectedGroup()
                }

                // Friend Tagging
                VStack(alignment: .leading) {
                    Text("Tag Friends")
                        .font(.headline)

                    ForEach(friends, id: \.self) { friend in
                        HStack {
                            Text(friend.name)
                            Spacer()
                            Image(systemName: taggedFriends.contains(friend) ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    toggleFriend(friend)
                                }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Upload Button
                Button(isPosting ? "Posting..." : "Post Snipe") {
                    guard let group = selectedGroup else { return }
                    isPosting = true
                    Task {
                        await viewModel.uploadSnipe(image: image, group: group, tagged: taggedFriends)
                        isPosting = false
                        showAlert = true
                    }
                }
                .disabled(isPosting || selectedGroup == nil)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Preview")
        .alert("Post Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.uploadStatus ?? "Posted successfully.")
        }
        .onAppear {
            loadGroupsForCurrentUser()
        }
    }

    // MARK: - Helpers

    func toggleFriend(_ friend: SnipUser) {
        if taggedFriends.contains(friend) {
            taggedFriends.removeAll { $0 == friend }
        } else {
            taggedFriends.append(friend)
        }
    }

    func loadGroupsForCurrentUser() {
        GroupService.shared.fetchGroupsForCurrentUser { result in
            switch result {
            case .success(let loadedGroups):
                self.groups = loadedGroups
            case .failure(let error):
                print("Failed to load groups: \(error.localizedDescription)")
            }
        }
    }

    func loadUsersForSelectedGroup() {
        guard let group = selectedGroup else { return }
        UserService.shared.fetchUsersInGroup(group: group) { result in
            switch result {
            case .success(let loadedUsers):
                self.friends = loadedUsers.filter { $0.email != Auth.auth().currentUser?.email }
            case .failure(let error):
                print("Failed to load users: \(error.localizedDescription)")
            }
        }
    }
}
