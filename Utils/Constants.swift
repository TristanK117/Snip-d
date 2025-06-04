//
//  Constants.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//  static strings like collection names, colors

import Foundation

enum Constants {
    // Firebase paths
    static let usersCollection = "users"
    static let groupsCollection = "groups"
    static let snipesCollection = "snipes"
    static let notificationsSubcollection = "notifications"

    // Storage
    static let storageSnipesPath = "snipes"

    // General UI
    static let maxGroupNameLength = 20
    static let maxTaggableFriends = 10
}
