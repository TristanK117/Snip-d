//
//  PostPreviewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit

@MainActor
class PostPreviewViewModel: ObservableObject {
    @Published var uploadStatus: String?

    func uploadSnipe(image: UIImage, group: SnipGroup, tagged: [SnipUser]) async {
        guard let email = Auth.auth().currentUser?.email else {
            uploadStatus = "User not authenticated"
            return
        }

        do {
            // Step 1: Upload image to Firebase Storage
            let filename = UUID().uuidString
            let imageURL = try await StorageService.shared.uploadImage(image, path: filename)

            // Step 2: Create a Snipe object
            let snipe = Snipe(
                id: nil,
                photoURL: imageURL.absoluteString,
                postedBy: email,
                groupName: group.name,
                timestamp: Date(),
                taggedUsers: tagged.map { $0.email }
            )

            // Step 3: Save to Firestore
            try FirebaseManager.shared.firestore
                .collection("snipes")
                .addDocument(from: snipe)

            // Step 4: Send notifications to tagged users
            await NotificationService.shared.sendBatchNotifications(
                to: tagged.map { $0.email },
                from: email,
                groupName: group.name
            )

            uploadStatus = "Snipe posted successfully!"
        } catch {
            uploadStatus = "Failed to post snipe: \(error.localizedDescription)"
        }
    }
}
