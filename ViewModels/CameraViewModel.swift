//
//  CameraViewModel.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import UIKit
import PhotosUI

@MainActor
class CameraViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var photoPickerItem: PhotosPickerItem?
    @Published var isShowingPostPreview = false

    func handlePhotoSelectionChange() async {
        guard let item = photoPickerItem else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                isShowingPostPreview = true
            }
        } catch {
            print("Failed to load image: \(error.localizedDescription)")
        }
    }

    func reset() {
        selectedImage = nil
        photoPickerItem = nil
        isShowingPostPreview = false
    }
}
