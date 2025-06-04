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
    var message: String
    var timestamp: Date
}
