//
//  SnipeService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/4/25.
//

import Foundation
import FirebaseFirestore

struct SnipeService {
    
    private static let snipesCollection = FirebaseManager.shared.firestore.collection("snipes")

    // Upload a new snipe (imageURL already uploaded)
    static func uploadSnipe(imageURL: String, tagged: [String], postedBy: String, groupId: String, groupName: String) async throws {
        let doc = snipesCollection.document()

        let snipeData: [String: Any] = [
            "id": doc.documentID,
            "imageURL": imageURL,
            "tagged": tagged,
            "postedBy": postedBy,
            "groupId": groupId,
            "groupName": groupName,
            "timestamp": Timestamp(date: Date())
        ]

        try await doc.setData(snipeData)
    }

    // Fetch snipes for a specific group
    static func fetchSnipes(forGroup groupId: String) async throws -> [Snipe] {
        let snapshot = try await snipesCollection
            .whereField("groupId", isEqualTo: groupId)
            .order(by: "timestamp", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            do {
                let data = try JSONSerialization.data(withJSONObject: doc.data())
                return try JSONDecoder().decode(Snipe.self, from: data)
            } catch {
                print("Failed to decode snipe: \(error)")
                return nil
            }
        }
    }

    // Fetch all snipes where the user is tagged
    static func fetchSnipes(taggedEmail: String) async throws -> [Snipe] {
        let snapshot = try await snipesCollection
            .whereField("tagged", arrayContains: taggedEmail)
            .order(by: "timestamp", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            do {
                let data = try JSONSerialization.data(withJSONObject: doc.data())
                return try JSONDecoder().decode(Snipe.self, from: data)
            } catch {
                print("Failed to decode snipe: \(error)")
                return nil
            }
        }
    }
}

