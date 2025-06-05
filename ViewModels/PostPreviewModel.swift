//
//  PostPreviewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//


import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

@MainActor
class PostPreviewViewModel: ObservableObject {
    @Published var uploadStatus: String?

    func uploadSnipe(image: UIImage, group: SnipGroup, tagged: [SnipUser]) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let currentUser = Auth.auth().currentUser,
              let email = currentUser.email else {
            uploadStatus = "Invalid image or user info."
            return
        }

        // Use group.id directly since it's not optional
        let groupId = group.id
        let snipeId = UUID().uuidString
        let storageRef = Storage.storage().reference().child("snipes/\(snipeId).jpg")

        do {
            _ = try await storageRef.putDataAsync(imageData)
            let downloadURL = try await storageRef.downloadURL()

            let snipeData: [String: Any] = [
                "id": snipeId,
                "imageURL": downloadURL.absoluteString,
                "tagged": tagged.map { $0.email },
                "postedBy": email,
                "groupId": groupId,
                "groupName": group.name,
                "timestamp": Date()
            ]

            try await Firestore.firestore().collection("snipes").document(snipeId).setData(snipeData)

            // Send notifications
            try await NotificationService.shared.sendBatchNotifications(
                to: tagged.map { $0.email },
                from: email,
                groupName: group.name
            )

            uploadStatus = "Post uploaded successfully."
        } catch {
            uploadStatus = "Upload failed: \(error.localizedDescription)"
        }
    }
}
