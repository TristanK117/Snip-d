//
//  CreateGroupView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct CreateGroupView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var groupName = ""
    @State private var isCreating = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Enter name", text: $groupName)
                }

                Section {
                    Button("Create Group") {
                        guard !groupName.isEmpty else { return }
                        isCreating = true
                        Task {
                            await viewModel.createGroup(name: groupName)
                            dismiss()
                        }
                    }
                    .disabled(isCreating || groupName.isEmpty)
                }
            }
            .navigationTitle("New Group")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}
