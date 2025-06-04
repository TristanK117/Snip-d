//
//  StorageService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseStorage
import UIKit

struct StorageService {
    private static let storageRef = FirebaseManager.shared.storage.reference()

    static func uploadImage(_ image: UIImage, path: String = UUID().uuidString) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to compress image"])
        }

        let imageRef = storageRef.child("snipes/\(path).jpg")
        let _ = try await imageRef.putDataAsync(imageData, metadata: nil)
        let url = try await imageRef.downloadURL()
        return url.absoluteString
    }
}
