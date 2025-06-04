//
//  CreateGroupView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var errorMessage: String?
    @State private var isCreating = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Create a Group")
                .font(.title2)
                .bold()

            TextField("Group Name", text: $groupName)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(isCreating ? "Creating..." : "Create Group") {
                Task {
                    isCreating = true
                    await createGroup()
                    isCreating = false
                }
            }
            .disabled(!Validators.isValidGroupName(groupName))
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }

    private func createGroup() async {
        guard Validators.isValidGroupName(groupName) else {
            errorMessage = "Group name must be non-empty and under \(Constants.maxGroupNameLength) characters."
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            return
        }

        let group = Group(id: nil, name: groupName.trimmed, memberIds: [uid])

        do {
            try await FirebaseManager.shared.firestore
                .collection(Constants.groupsCollection)
                .addDocument(from: group)
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
        }
    }
}

