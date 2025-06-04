//
//  UserService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseFirestore

class UserService {
    static let shared = UserService()
    private init() {}

    private let db = Firestore.firestore()

    func fetchAllUsers() async throws -> [SnipUser] {
        let snapshot = try await db.collection("users").getDocuments()
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: SnipUser.self)
        }
    }

    func fetchUser(byEmail email: String) async throws -> SnipUser? {
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()

        return try snapshot.documents.first?.data(as: SnipUser.self)
    }

    func fetchUsersInGroup(group: SnipGroup, completion: @escaping (Result<[SnipUser], Error>) -> Void) {
        let emails = group.members
        db.collection("users")
            .whereField("email", in: emails)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let docs = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                do {
                    let users = try docs.map { try $0.data(as: SnipUser.self) }
                    completion(.success(users))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    func createUser(_ user: SnipUser) async throws {
        try db.collection("users").document(user.uid).setData(from: user)
    }
}
