//
//  ProfileViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userEmail: String?
    @Published var taggedSnipes: [Snipe] = []

    func fetchTaggedSnipes() {
        guard let email = Auth.auth().currentUser?.email else { return }
        self.userEmail = email

        Task {
            do {
                let result = try await SnipeService.fetchSnipes(taggedEmail: email)
                self.taggedSnipes = result
            } catch {
                print("Failed to fetch tagged snipes: \(error)")
            }
        }
    }
}
