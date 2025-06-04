//
//  MockData.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

struct Group: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
}
