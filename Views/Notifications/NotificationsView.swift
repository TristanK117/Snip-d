//
//  NotificationsView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.notifications) { notif in
                VStack(alignment: .leading) {
                    Text(notif.message)
                        .font(.body)
                    Text(notif.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Notifications")
            .onAppear {
                viewModel.loadNotifications()
            }
        }
    }
}

