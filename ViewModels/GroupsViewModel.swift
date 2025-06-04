//
//  GroupsViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var selectedGroup: Group?

    func fetchGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("groups")
            .whereField("memberIds", arrayContains: uid)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let snapshot = snapshot {
                        self.groups = snapshot.documents.compactMap {
                            try? $0.data(as: Group.self)
                        }
                    }
                }
            }
    }

    func createGroup(name: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let group = Group(id: nil, name: name, memberIds: [uid])

        do {
            _ = try Firestore.firestore().collection("groups").addDocument(from: group)
        } catch {
            print("Error creating group: \(error)")
        }
    }
}
