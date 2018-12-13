//
//  ViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/12/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // https://simple-chat-d11ee.firebaseio.com/
        
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        }
        
        
        view.backgroundColor = .white
        let logOutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem = logOutButton
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()

        } catch {print(error)}
        
        let viewController = LoginViewController()
        self.present(viewController, animated: true, completion: nil)
        
        
    }
    
    
}
