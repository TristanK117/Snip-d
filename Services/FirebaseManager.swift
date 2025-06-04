//
//  FirebaseManager.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseManager {
    static let shared = FirebaseManager()

    let auth: Auth
    let firestore: Firestore
    let storage: Storage

    private init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
    }
}
