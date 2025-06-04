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
            List(viewModel.notifications) { notification in
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔔 Tagged by \(notification.fromEmail)")
                        .font(.headline)
                    Text("Group: \(notification.groupName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(notification.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Alerts")
            .onAppear {
                Task {
                    await viewModel.loadNotifications()
                }
            }
        }
    }
}
