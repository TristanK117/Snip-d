//
//  ContentSheetWrapper.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/4/25.
//

import SwiftUI

struct SheetContentWrapper: View {
    @ObservedObject var viewModel: CameraViewModel
    let group: SnipGroup?
    let taggedUsers: [SnipUser]

    var body: some View {
        if let image = viewModel.selectedImage,
           let group = group,
           !taggedUsers.isEmpty {
            PostPreviewView(
                image: image,
                group: group,
                taggedUsers: taggedUsers
            )
        } else {
            VStack(spacing: 12) {
                Text("Missing group, tagged users, or image.")
                    .multilineTextAlignment(.center)
                Button("Dismiss") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}
