//
//  Validators.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//  for email/password input checks


import Foundation

enum Validators {
    static func isValidEmail(_ email: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    static func isValidGroupName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               name.count <= Constants.maxGroupNameLength
    }
}
