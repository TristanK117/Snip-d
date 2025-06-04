//
//  FeedViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    @Published var snipes: [Snipe] = []
    @Published var errorMessage: String?

    func loadSnipes() {
        FirestoreService.shared.fetchSnipes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let snipes):
                    self.snipes = snipes
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
