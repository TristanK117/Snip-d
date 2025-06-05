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

    static func createGroup(name: String, creatorEmail: String) async throws {
        let doc = groupsCollection.document()

        let groupData: [String: Any] = [
            "id": doc.documentID,
            "name": name,
            "members": [creatorEmail],
            "createdBy": creatorEmail,
            "timestamp": Timestamp(date: Date())
        ]

        try await doc.setData(groupData)
    }


    static func fetchGroups(for email: String) async throws -> [SnipGroup] {
        let snapshot = try await groupsCollection.whereField("members", arrayContains: email).getDocuments()


        return try snapshot.documents.compactMap { doc in
            try doc.data(as: SnipGroup.self)
        }
    }


    static func joinGroup(groupId: String, userEmail: String) async throws {
        let docRef = groupsCollection.document(groupId)
        try await docRef.updateData([
            "members": FieldValue.arrayUnion([userEmail])
        ])
    }

    static func addMembers(to groupId: String, emails: [String]) async throws {
        let docRef = groupsCollection.document(groupId)
        try await docRef.updateData([
            "members": FieldValue.arrayUnion(emails)
        ])
    }

    static func removeMember(from groupId: String, email: String) async throws {
        let docRef = groupsCollection.document(groupId)
        try await docRef.updateData([
            "members": FieldValue.arrayRemove([email])
        ])
    }

    static func fetchGroup(byId id: String) async throws -> SnipGroup {
        let doc = try await groupsCollection.document(id).getDocument()
        

        return try doc.data(as: SnipGroup.self)
    }
}
