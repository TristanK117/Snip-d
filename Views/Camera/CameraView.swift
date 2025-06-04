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

    // Inject or select these values from elsewhere in your app
    @State private var selectedGroup: SnipGroup? = nil
    @State private var taggedUsers: [SnipUser] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                PhotosPicker(
                    selection: $viewModel.photoPickerItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                .frame(height: 200)

                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                    Text("Select a Photo")
                                }
                                .foregroundColor(.gray)
                            }
                        }
                    }

                if viewModel.selectedImage != nil {
                    Button("Next") {
                        viewModel.isShowingPostPreview = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
            }
            .padding()
            .navigationTitle("Camera")
            .onChange(of: viewModel.photoPickerItem) { oldValue, newValue in
                Task {
                    await viewModel.handlePhotoSelectionChange()
                }
            }
            .sheet(isPresented: $viewModel.isShowingPostPreview) {
                SheetContentWrapper(
                    viewModel: viewModel,
                    group: selectedGroup,
                    taggedUsers: taggedUsers
                )
            }
        }
    }
}
