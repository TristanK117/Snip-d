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
    @State private var showPreview = false
    @State private var showPhotoPicker = false

    var body: some View {
        VStack(spacing: 20) {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }

            Button("Take Photo") {
                showPhotoPicker = true
            }

            if selectedImage != nil {
                NavigationLink(destination: PostPreviewView(image: selectedImage!), isActive: $showPreview) {
                    EmptyView()
                }

                Button("Next") {
                    showPreview = true
                }
            }
        }
        .padding()
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedImage)
    }
}
