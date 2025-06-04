//
//  NotificationsView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: Date
}

struct NotificationsView: View {
    // Mock notification data
    let notifications = [
        NotificationItem(message: "You were sniped by Jamie in Dorm 2B", timestamp: Date().addingTimeInterval(-3600)),
        NotificationItem(message: "Nina tagged you in UW Friends", timestamp: Date().addingTimeInterval(-7200))
    ]

    var body: some View {
        NavigationView {
            List(notifications) { notif in
                VStack(alignment: .leading, spacing: 4) {
                    Text(notif.message)
                        .font(.body)
                    Text(notif.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Notifications")
        }
    }
}
