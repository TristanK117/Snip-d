//
//  FirebaseManager.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    let storage: Storage

    private init() {
        // REMOVED: FirebaseApp.configure() - already configured in AppDelegate
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
    }
}
