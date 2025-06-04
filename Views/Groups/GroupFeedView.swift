//
//  GroupFeedView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/4/25.
//

import SwiftUI

struct GroupFeedView: View {
    let group: SnipGroup

    var body: some View {
        VStack {
            Text("Snipes for \(group.name)")
                .font(.title)
                .padding()

            Spacer()

            Text("This is where snipes for this group will be displayed.")
                .foregroundColor(.gray)

            Spacer()
        }
        .navigationTitle(group.name)
    }
}
