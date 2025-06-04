//
//  NotificationService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import FirebaseFirestore

final class NotificationService {
    static let shared = NotificationService()
    private let db = FirebaseManager.shared.firestore

    private init() {}

    func sendSnipeNotification(to userEmail: String, from sender: String, groupName: String) async {
        do {
            // Get UID for tagged user
            let snapshot = try await db.collection("users")
                .whereField("email", isEqualTo: userEmail)
                .getDocuments()

            guard let doc = snapshot.documents.first,
                  let userId = doc.documentID as String? else { return }

            let notif = NotificationItem(
                id: nil,
                message: "\(sender) sniped you in \(groupName)!",
                timestamp: Date()
            )

            try db.collection("users")
                .document(userId)
                .collection("notifications")
                .addDocument(from: notif)
        } catch {
            print("Failed to send notification: \(error)")
        }
    }

    func sendBatchNotifications(to emails: [String], from sender: String, groupName: String) async {
        for email in emails {
            await sendSnipeNotification(to: email, from: sender, groupName: groupName)
        }
    }
}
