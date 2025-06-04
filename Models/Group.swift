//
//  Group.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//  id, name, members

import Foundation
import FirebaseFirestoreSwift

struct Group: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var memberIds: [String]  // Array of user UIDs
}
