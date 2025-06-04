//
//  CreateGroupView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Enter group name", text: $groupName)
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button("Create Group") {
                    Task {
                        await createGroup()
                    }
                }
            }
            .navigationTitle("New Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func createGroup() async {
        guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Group name cannot be empty."
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not signed in."
            return
        }

        let groupData: [String: Any] = [
            "name": groupName,
            "memberIds": [uid]
        ]

        do {
            try await Firestore.firestore().collection("groups").addDocument(data: groupData)
            dismiss()
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
        }
    }
}

