//
//  UserService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()

    private init() {}

    func fetchUsersInGroup(group: SnipGroup, completion: @escaping (Result<[SnipUser], Error>) -> Void) {
        guard !group.memberIds.isEmpty else {
            completion(.success([]))
            return
        }

        db.collection("users")
            .whereField("uid", in: group.memberIds)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let users = snapshot?.documents.compactMap {
                        try? $0.data(as: SnipUser.self)
                    } ?? []
                    completion(.success(users))
                }
            }
    }
}

