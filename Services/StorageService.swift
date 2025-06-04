//
//  StorageService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import FirebaseStorage
import UIKit

final class StorageService {
    static let shared = StorageService()
    private let storageRef = FirebaseManager.shared.storage.reference()

    private init() {}

    func uploadImage(_ image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 0, userInfo: nil)
        }

        let imageRef = storageRef.child("snipes/\(path).jpg")
        _ = try await imageRef.putDataAsync(data, metadata: nil)
        return try await imageRef.downloadURL()
    }
}
