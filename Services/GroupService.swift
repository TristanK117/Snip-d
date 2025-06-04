//
//  GroupService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

struct GroupService {
    static let shared = GroupService()
    private init() {}
    
    func fetchGroupsForCurrentUser() async throws -> [SnipGroup] {
        guard let email = Auth.auth().currentUser?.email else { return [] }

        let snapshot = try await Firestore.firestore()
            .collection("groups")
            .whereField("members", arrayContains: email)
            .getDocuments()

        return try snapshot.documents.compactMap { try $0.data(as: SnipGroup.self) }
    }
    
    private static let groupsCollection = FirebaseManager.shared.firestore.collection("groups")

    // Create a new group
    static func createGroup(name: String, creatorEmail: String) async throws {
        let doc = groupsCollection.document()  // Auto-generated ID

        let groupData: [String: Any] = [
            "id": doc.documentID,
            "name": name,
            "members": [creatorEmail],
            "createdBy": creatorEmail,
            "timestamp": Timestamp(date: Date())
        ]

        try await doc.setData(groupData)
    }

    // Fetch all groups the current user is a member of
    static func fetchGroups(for email: String) async throws -> [SnipGroup] {
        let snapshot = try await groupsCollection.whereField("members", arrayContains: email).getDocuments()

        return snapshot.documents.compactMap { doc in
            do {
                let data = try JSONSerialization.data(withJSONObject: doc.data())
                return try JSONDecoder().decode(SnipGroup.self, from: data)
            } catch {
                print("Failed to decode group: \(error)")
                return nil
            }
        }
    }

    // Join an existing group by ID
    static func joinGroup(groupId: String, userEmail: String) async throws {
        let docRef = groupsCollection.document(groupId)
        try await docRef.updateData([
            "members": FieldValue.arrayUnion([userEmail])
        ])
    }

    // Fetch a single group
    static func fetchGroup(byId id: String) async throws -> SnipGroup {
        let doc = try await groupsCollection.document(id).getDocument()
        guard let data = doc.data() else {
            throw NSError(domain: "GroupService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not found"])
        }

        let json = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(SnipGroup.self, from: json)
    }
}
