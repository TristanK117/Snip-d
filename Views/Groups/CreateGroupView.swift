//
//  CreateGroupView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct CreateGroupView: View {
    @Binding var groups: [Group]
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Enter group name", text: $groupName)
                }

                Button("Add Group") {
                    if !groupName.isEmpty {
                        groups.append(Group(name: groupName))
                        dismiss()
                    }
                }
                .disabled(groupName.isEmpty)
            }
            .navigationTitle("Create Group")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
