//
//  User.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//  name, id, groups, AvatarURL
import Foundation
import FirebaseFirestore

struct SnipUser: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var uid: String
    var name: String
    var email: String
    var avatarURL: String?
}

