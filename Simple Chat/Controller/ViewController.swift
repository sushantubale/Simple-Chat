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
        
        view.backgroundColor = .white
        let logOutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem = logOutButton
        let newMessageButton = UIBarButtonItem(image: UIImage(named: "new_message"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(newMessageTapped))
        navigationItem.rightBarButtonItem = newMessageButton
        
//        checkUserLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkUserLoggedIn()
    }
    
    @objc func newMessageTapped() {
        
        let messageViewController = MessageViewController()
        let navController = UINavigationController(rootViewController: messageViewController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkUserLoggedIn() {
        
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        }
        else {
            guard  let uid = Auth.auth().currentUser?.uid else {return}
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    DispatchQueue.main.async {
                        self.navigationItem.title = dictionary["name"] as? String
                    }
                }
                
                

            }
        }
        

    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()

        } catch {print(error)}
        
        let viewController = LoginViewController()
        self.present(viewController, animated: true, completion: nil)
        
        
    }
    
    
}
