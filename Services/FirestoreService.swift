//
//  FirestoreService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    func fetchSnipes(completion: @escaping (Result<[Snipe], Error>) -> Void) {
        db.collection("snipes")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let snipes = snapshot?.documents.compactMap {
                        try? $0.data(as: Snipe.self)
                    } ?? []
                    completion(.success(snipes))
                }
            }
    }
}

