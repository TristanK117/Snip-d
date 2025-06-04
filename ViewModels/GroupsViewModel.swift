//
//  GroupsViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var groups: [SnipGroup] = []
    @Published var isLoading: Bool = false
    @Published var showingGroupCreation: Bool = false
    @Published var errorMessage: String?

    func fetchGroups() async {
        guard let email = Auth.auth().currentUser?.email else {
            errorMessage = "User not authenticated"
            return
        }

        isLoading = true

        do {
            let fetchedGroups = try await GroupService.fetchGroups(for: email)
            self.groups = fetchedGroups
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createGroup(name: String) async {
        guard let email = Auth.auth().currentUser?.email else {
            errorMessage = "User not authenticated"
            return
        }

        do {
            try await GroupService.createGroup(name: name, creatorEmail: email)
            await fetchGroups()
            showingGroupCreation = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func joinGroup(groupId: String) async {
        guard let email = Auth.auth().currentUser?.email else {
            errorMessage = "User not authenticated"
            return
        }

        do {
            try await GroupService.joinGroup(groupId: groupId, userEmail: email)
            await fetchGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
