//
//  NotificationItem.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseFirestore

struct NotificationItem: Identifiable, Codable {
    @DocumentID var id: String?
    var toEmail: String
    var fromEmail: String
    var groupName: String
    var timestamp: Date
}
