//
//  ProfileViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userEmail: String? = Auth.auth().currentUser?.email
    @Published var taggedSnipes: [Snipe] = []
    @Published var errorMessage: String?

    func fetchTaggedSnipes() {
        guard let email = userEmail else { return }

        Firestore.firestore().collection("snipes")
            .whereField("taggedUsers", arrayContains: email)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    self.taggedSnipes = snapshot?.documents.compactMap {
                        try? $0.data(as: Snipe.self)
                    } ?? []
                }
            }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
}
