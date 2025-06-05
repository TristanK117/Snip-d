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

    func fetchUser(byEmail email: String) async throws -> SnipUser? {
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()

        return try snapshot.documents.first?.data(as: SnipUser.self)
    }

    func fetchUsersInGroup(group: SnipGroup, completion: @escaping (Result<[SnipUser], Error>) -> Void) {
        let emails = group.members
        
        print("DEBUG: fetchUsersInGroup called for group: \(group.name)")
        print("DEBUG: Group member emails: \(emails)")
        
        guard !emails.isEmpty else {
            print("DEBUG: No emails in group")
            completion(.success([]))
            return
        }
        
        // Split into chunks of 10 (Firestore limitation for 'in' queries)
        let chunks = emails.chunked(into: 10)
        var allUsers: [SnipUser] = []
        let group = DispatchGroup()
        var fetchError: Error?
        
        for chunk in chunks {
            print("DEBUG: Fetching chunk: \(chunk)")
            group.enter()
            db.collection("users")
                .whereField("email", in: chunk)
                .getDocuments { snapshot, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("DEBUG: Error fetching users: \(error)")
                        fetchError = error
                        return
                    }
                    
                    guard let docs = snapshot?.documents else {
                        print("DEBUG: No documents returned")
                        return
                    }
                    
                    print("DEBUG: Found \(docs.count) user documents")
                    
                    do {
                        let users = try docs.map { try $0.data(as: SnipUser.self) }
                        print("DEBUG: Successfully decoded \(users.count) users")
                        for user in users {
                            print("DEBUG: User: \(user.name) (\(user.email))")
                        }
                        allUsers.append(contentsOf: users)
                    } catch {
                        print("DEBUG: Error decoding users: \(error)")
                        fetchError = error
                    }
                }
        }
        
        group.notify(queue: .main) {
            print("DEBUG: Final result - \(allUsers.count) users loaded")
            if let error = fetchError {
                completion(.failure(error))
            } else {
                completion(.success(allUsers))
            }
        }
    }

    func createUser(_ user: SnipUser) async throws {
        try db.collection("users").document(user.uid).setData(from: user)
    }
}

// Helper extension for chunking arrays
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
