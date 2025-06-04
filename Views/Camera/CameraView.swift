//
//  CameraView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        VStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }

            PhotosPicker("Pick Photo", selection: $viewModel.photoPickerItem, matching: .images)
                .onChange(of: viewModel.photoPickerItem) { _ in
                    Task {
                        await viewModel.handlePhotoSelectionChange()
                    }
                }

            if viewModel.selectedImage != nil {
                NavigationLink(destination: PostPreviewView(image: viewModel.selectedImage!), isActive: $viewModel.isShowingPostPreview) {
                    EmptyView()
                }

                Button("Next") {
                    viewModel.isShowingPostPreview = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

