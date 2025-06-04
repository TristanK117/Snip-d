//
//  Extensions.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//  View, Date, Image extensions

import SwiftUI

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - String Extensions
extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isEmail: Bool {
        Validators.isValidEmail(self)
    }
}

// MARK: - Date Extensions
extension Date {
    func formattedRelative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
