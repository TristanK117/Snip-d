//
//  Snipe.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//  PHoto post
//  PhotoURL, tagged users, timestamp

import FirebaseFirestore


struct Snipe: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURL: String
    var postedBy: String
    var tagged: [String]
    var groupId: String
    var groupName: String
    var timestamp: Date
}



