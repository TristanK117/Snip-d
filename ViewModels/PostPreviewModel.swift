//
//  PostPreviewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

@MainActor
class PostPreviewViewModel: ObservableObject {
    @Published var uploadStatus: String?

    func uploadSnipe(image: UIImage, group: Group, tagged: [User]) async {
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else { return }

        do {
            let url = try await uploadImageToStorage(image: image)

            let snipe = Snipe(
                photoURL: url.absoluteString,
                postedBy: email,
                groupName: group.name,
                timestamp: Date(),
                taggedUsers: tagged.map { $0.email }
            )

            try Firestore.firestore().collection("snipes").addDocument(from: snipe)
            uploadStatus = "Success"
        } catch {
            uploadStatus = "Upload failed: \(error.localizedDescription)"
        }
    }

    private func uploadImageToStorage(image: UIImage) async throws -> URL {
        let ref = Storage.storage().reference().child("snipes/\(UUID().uuidString).jpg")

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 0, userInfo: nil)
        }

        _ = try await ref.putDataAsync(data, metadata: nil)
        return try await ref.downloadURL()
    }
}

