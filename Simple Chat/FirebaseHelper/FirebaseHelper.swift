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
}
