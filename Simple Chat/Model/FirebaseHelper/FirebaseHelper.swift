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
    
    static func childAddedObserver(ref: DatabaseReference, completion: @escaping (DataSnapshot?) -> ()) {
        
        ref.observe(.childAdded, with: { (snapshot) in
            completion(snapshot)
        }, withCancel: nil)
    }
    
    static func deleteMessagesFromOutside(ref: DatabaseReference, completion: @escaping (DataSnapshot?) -> ()) {
        
        ref.observe(DataEventType.childRemoved, with: { (snapshot) in
            completion(snapshot)
        }, withCancel: nil)
    }
    
    static func logout() {
        
        do {
            try Auth.auth().signOut()
        } catch {print("error logging out")}
    }
    
    static func fetchUsers(ref: DatabaseReference, completion: @escaping (DataSnapshot?) -> ()) {
        
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            completion(snapshot)
            }, withCancel: nil)
    }
    
    static func observeSingleEventOfValue(userMessageRef: DatabaseReference, completion: @escaping (DataSnapshot?) -> ()) {
    
        userMessageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot)
        }, withCancel: nil)
    }
    
    static func putFiletoFirebase(uploadTask: StorageReference, videoUrl: URL, completion: @escaping (StorageMetadata?, Error?) -> ()) {
        
        uploadTask.putFile(from: videoUrl, metadata: nil) { (responseMetadata, error) in
            
            if error != nil {
                print(error as Any)
                completion(nil, error)
            } else {
                completion(responseMetadata, error)
            }
        }
    }
}
