//
//  AuthService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import FirebaseAuth
import FirebaseFirestore

struct AuthService {
    static func registerUser(email: String, password: String, name: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = authResult.user.uid

        let userData: [String: Any] = [
            "uid": uid,
            "name": name,
            "email": email,
            "avatarURL": "" // Placeholder or default avatar
        ]

        try await Firestore.firestore().collection("users").document(uid).setData(userData)
    }

    static func loginUser(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    static func logoutUser() throws {
        try Auth.auth().signOut()
    }

    static func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}
