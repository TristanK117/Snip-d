//
//  PostPreviewView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI
import FirebaseAuth

struct PostPreviewView: View {
    let image: UIImage
    let group: SnipGroup
    let taggedUsers: [SnipUser]

    @StateObject private var viewModel = PostPreviewViewModel()
    @State private var isPosting = false
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)

                VStack(alignment: .leading) {
                    Text("Group: \(group.name)")
                        .font(.headline)

                    Text("Tagged Friends:")
                        .font(.subheadline)
                        .padding(.top, 4)

                    ForEach(taggedUsers, id: \.self) { user in
                        Text(user.name)
                    }
                }

                Button(action: {
                    isPosting = true
                    Task {
                        await viewModel.uploadSnipe(image: image, group: group, tagged: taggedUsers)
                        isPosting = false
                        showAlert = true
                    }
                }) {
                    Text(isPosting ? "Posting..." : "Post Snipe")
                }
                .disabled(isPosting)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Preview")
        .alert("Post Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.uploadStatus ?? "Posted successfully.")
        }
    }
}
