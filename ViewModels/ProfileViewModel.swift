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
    @Published var userEmail: String?
    @Published var taggedSnipes: [Snipe] = []
    @Published var errorMessage: String?

    init() {
        loadUserInfo()
        fetchTaggedSnipes()
    }

    func loadUserInfo() {
        userEmail = Auth.auth().currentUser?.email
    }

    func fetchTaggedSnipes() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }

        Firestore.firestore().collection("snipes")
            .whereField("taggedUsers", arrayContains: userEmail)
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
}
