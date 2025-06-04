//
//  FeedViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FeedViewModel: ObservableObject {
    @Published var snipes: [Snipe] = []
    @Published var errorMessage: String?

    func loadSnipes() {
        Firestore.firestore().collection("snipes")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    self.snipes = snapshot?.documents.compactMap {
                        try? $0.data(as: Snipe.self)
                    } ?? []
                }
            }
    }
}

