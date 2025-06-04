//
//  GroupsView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct GroupsView: View {
    @State private var selectedGroup: Group?
    @State private var groups: [Group] = [
        Group(name: "UW Friends"),
        Group(name: "Dorm 2B"),
        Group(name: "Gym Buddies")
    ]

    @State private var newGroupName = ""
    @State private var showCreateGroup = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                List(selection: $selectedGroup) {
                    ForEach(groups) { group in
                        HStack {
                            Text(group.name)
                            Spacer()
                            if selectedGroup == group {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle()) // Makes whole row tappable
                        .onTapGesture {
                            selectedGroup = group
                        }
                    }
                }

                Button("Create New Group") {
                    showCreateGroup = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Your Groups")
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView(groups: $groups)
            }
        }
    }
}
