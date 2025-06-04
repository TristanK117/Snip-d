//
//  GroupService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class GroupService {
    static let shared = GroupService()
    private let db = Firestore.firestore()

    private init() {}

    func fetchGroupsForCurrentUser(completion: @escaping (Result<[SnipGroup], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        db.collection("groups")
            .whereField("memberIds", arrayContains: uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error)) 
                } else {
                    let groups = snapshot?.documents.compactMap {
                        try? $0.data(as: SnipGroup.self)
                    } ?? []
                    completion(.success(groups))
                }
            }
    }
}
