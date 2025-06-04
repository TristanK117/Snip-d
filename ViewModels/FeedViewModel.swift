//
//  FeedViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class FeedViewModel: ObservableObject {
    @Published var snipes: [Snipe] = []

    func loadSnipes() {
        Firestore.firestore().collection("snipes")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error loading snipes: \(error?.localizedDescription ?? "unknown")")
                    return
                }

                var results: [Snipe] = []

                for document in documents {
                    do {
                        let snipe = try document.data(as: Snipe.self)
                        results.append(snipe)
                    } catch {
                        print("Error decoding snipe: \(error)")
                    }
                }

                DispatchQueue.main.async {
                    self.snipes = results
                }
            }
    }
}


