//
//  FeedViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth

@MainActor
class FeedViewModel: ObservableObject {
    @Published var snipes: [Snipe] = []

    func loadSnipes(groupId: String) async {
        do {
            let result = try await SnipeService.fetchSnipes(forGroup: groupId)
            self.snipes = result
        } catch {
            print("Failed to load snipes: \(error)")
        }
    }
    func loadAllUserSnipes() async {
        guard let email = Auth.auth().currentUser?.email else { return }
        do {
            let groups = try await GroupService.fetchGroups(for: email)
            var allSnipes: [Snipe] = []

            for group in groups {
                guard let id = group.id else { continue }
                let groupSnipes = try await SnipeService.fetchSnipes(forGroup: id)
                allSnipes.append(contentsOf: groupSnipes)
            }

            self.snipes = allSnipes.sorted(by: { $0.timestamp > $1.timestamp })
        } catch {
            print("Failed to load home feed: \(error.localizedDescription)")
        }
    }
}

