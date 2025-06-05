//
//  Group.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//  id, name, members

import Foundation
import FirebaseFirestore

struct SnipGroup: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let members: [String]
    let createdBy: String
    let timestamp: Timestamp
    
    var createdDate: Date {
        return timestamp.dateValue()
    }
}
