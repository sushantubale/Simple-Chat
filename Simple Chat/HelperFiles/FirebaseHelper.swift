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

    static  func handlelogin(_ emailTextField: String?,_ passwordTextField: String?, completion: @escaping (Error?) -> Void) {
        
        guard let email = emailTextField, let password = passwordTextField else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(error)
            } else {
                completion(nil)
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
}
