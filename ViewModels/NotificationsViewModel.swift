//
//  NotificationsViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []

    func loadNotifications() async {
        guard let email = Auth.auth().currentUser?.email else { return }
        
        do {
            notifications = try await NotificationService.shared.fetchNotifications(for: email)
        } catch {
            print("Failed to load notifications: \(error)")
        }
    }
}
