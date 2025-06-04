//
//  AuthService.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AuthService {
    
    static func registerUser(email: String, password: String, name: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = result.user

        let snipUser = SnipUser(
            id: user.uid,
            uid: user.uid,
            name: name,
            email: user.email ?? "",
            avatarURL: nil
        )

        try await Firestore.firestore().collection("users").document(user.uid).setData(from: snipUser)
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
