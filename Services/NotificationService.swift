//
//  NotificationService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseFirestore

class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let notificationsCollection = FirebaseManager.shared.firestore.collection("notifications")

    func sendNotification(to toEmail: String, from fromEmail: String, groupName: String) async throws {
        let doc = notificationsCollection.document()
        
        let notificationData: [String: Any] = [
            "id": doc.documentID,
            "toEmail": toEmail,
            "fromEmail": fromEmail,
            "groupName": groupName,
            "timestamp": Timestamp(date: Date())
        ]

        try await doc.setData(notificationData)
    }

    func sendBatchNotifications(to taggedEmails: [String], from senderEmail: String, groupName: String) async {
        for email in taggedEmails where email != senderEmail {
            do {
                try await sendNotification(to: email, from: senderEmail, groupName: groupName)
            } catch {
                print("Failed to send notification to \(email): \(error)")
            }
        }
    }

    func fetchNotifications(for email: String) async throws -> [NotificationItem] {
        let snapshot = try await notificationsCollection
            .whereField("toEmail", isEqualTo: email)
            .order(by: "timestamp", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            do {
                let data = try JSONSerialization.data(withJSONObject: doc.data())
                return try JSONDecoder().decode(NotificationItem.self, from: data)
            } catch {
                print("Failed to decode notification: \(error)")
                return nil
            }
        }
    }
}
