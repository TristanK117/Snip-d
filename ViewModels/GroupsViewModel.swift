//
//  GroupsViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var groups: [SnipGroup] = []
    @Published var isLoading = false
    @Published var showingGroupCreation = false

    func fetchGroups() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("groups")
                .getDocuments()

            self.groups = try snapshot.documents.map {
                try $0.data(as: SnipGroup.self)
            }
        } catch {
            print("Error fetching groups: \(error)")
        }
    }
}
