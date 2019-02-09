//
//  FirebaseHelper.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/9/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class FirebaseHelper: NSObject {

    static func handleLogin(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> ()) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                completion(nil, error)
            } else {
                completion(authDataResult, nil)
            }
         }
    }
    
    static func handleRegister(email: String, password: String, name: String, completion: @escaping (AuthDataResult?, Error?) -> ()) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                completion(nil, error)
            } else {
                completion(authDataResult, nil)
            }
        }
    }
    
    static func storeData(compressedImage: Data, storageRef: StorageReference, completion: @escaping (StorageMetadata?, Error?) -> ()) {
        
        storageRef.putData(compressedImage, metadata: nil) { (metadata, error) in
            
            if error != nil {
                completion(nil, error)
            } else {
                completion(metadata, nil)
            }
        }
        
    }
}