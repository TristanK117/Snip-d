//
//  PostPreviewView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct PostPreviewView: View {
    let image: UIImage

    @State private var selectedGroup: Group?
    @State private var taggedFriends: [User] = []
    @State private var showConfirmation = false

    // Mock data
    let mockGroups = [
        Group(name: "UW Friends"),
        Group(name: "Dorm 2B"),
        Group(name: "Gym Buddies")
    ]

    let mockFriends = [
        User(name: "Tristan"),
        User(name: "Jamie"),
        User(name: "Lee"),
        User(name: "Nina")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)

                // Group Picker
                Picker("Select Group", selection: $selectedGroup) {
                    ForEach(mockGroups) { group in
                        Text(group.name).tag(Optional(group))
                    }
                }
                .pickerStyle(.menu)

                // Tag Friends (Multi-Select)
                VStack(alignment: .leading) {
                    Text("Tag Friends:")
                        .font(.headline)
                    ForEach(mockFriends) { friend in
                        HStack {
                            Text(friend.name)
                            Spacer()
                            Image(systemName: taggedFriends.contains(friend) ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    toggleFriend(friend)
                                }
                        }
                        .padding(.horizontal)
                    }
                }

                Button("Post Snipe") {
                    // Post confirmation for now
                    showConfirmation = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Preview")
        .alert("Snipe Posted!", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) { }
        }
    }

    func toggleFriend(_ friend: User) {
        if let index = taggedFriends.firstIndex(of: friend) {
            taggedFriends.remove(at: index)
        } else {
            taggedFriends.append(friend)
        }
    }
}
