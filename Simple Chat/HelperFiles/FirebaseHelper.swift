//
//  FirebaseHelper.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/6/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class FirebaseHelper: NSObject {

    static let userMessages = Database.database().reference().child("user-messages")
    static let messages = Database.database().reference().child("messages")
    static let authUid = Auth.auth().currentUser?.uid
    static let userNode = Database.database().reference().child("users")
    
    static  func handlelogin(_ emailTextField: String?,_ passwordTextField: String?, completion: @escaping (Error?, AuthDataResult?) -> Void) {
    
        guard let email = emailTextField, let password = passwordTextField else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(error, nil)
            } else {
                completion(nil, user)
            }
        }
    }
    
    
    static func handleRegister(_ emailTextField: String,_ passwordTextField: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: emailTextField, password: passwordTextField) { (user, error) in
            
            if error != nil {
                completion(nil, nil)

            }
            else {
                completion(user, error)

            }

        }
    }
    
    static func storeUserData(uid: String, values: [String: AnyObject], completion: @escaping (Error?, DatabaseReference?) -> Void) {
        
        let ref = Database.database().reference(fromURL: "https://simple-chat-26867.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
            if error != nil {
                completion(error, nil)
            } else {
                completion(nil, reference)
            }
        })
    }
    
    static func observeMessages(completion: @escaping (DataSnapshot?) -> Void) {
        
        messages.observe(.childAdded) { (snapshot) in
            completion(snapshot)
        }
    }
    
    static func deleteMessagesFromOutside(completion: @escaping (DataSnapshot?) -> Void) {
        
        userMessages.observe(.childRemoved, with: { (snapshot) in
            completion(snapshot)
        }, withCancel: nil)

    }
    
    static func fetchUserAndSetNavTitle(completion: @escaping (DataSnapshot?) -> Void) {
        
        guard let authUid = authUid else {
            return
        }
        
        userNode.child(authUid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot)
        }
    }
    
    static func messageControllerTableView(message1: String?, completion: @escaping (DataSnapshot?) -> Void) {
    
        guard let message1 = message1 else {
            return
        }
        userNode.child(message1).observe(.value) { (snapshot) in
            completion(snapshot)
        }
    
    }
    
    static func deleteMessagesFromTableView(chatPartnerId: String?, completion: @escaping (Error?, DatabaseReference?) -> Void) {
    
        guard let authUid = authUid, let chatPartnerId = chatPartnerId else {
            return
        }
        userMessages.child(authUid).child(chatPartnerId).removeValue { (error, reference) in
            if error != nil {
                completion(error, nil)
            }
            completion(nil, reference)
        }
    }
    
    static func setNameAndProfileImage(id: String, completion: @escaping (DataSnapshot?) -> Void) {
        
        userNode.child(id).observe(.value, with: { (snapshot) in
            completion(snapshot)
            
        }, withCancel: nil)

    }
    
    static func logout() {
        
        do {
            try Auth.auth().signOut()
            
        } catch {print(error)}
    }
}
