//
//  CameraView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    @State private var selectedImage: UIImage?
    @State private var showPostPreview = false
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }

            PhotosPicker("Pick Photo", selection: $photoPickerItem, matching: .images)
                .padding()

            if selectedImage != nil {
                NavigationLink(destination: PostPreviewView(image: selectedImage!), isActive: $showPostPreview) {
                    EmptyView()
                }

                Button("Next") {
                    showPostPreview = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
}

