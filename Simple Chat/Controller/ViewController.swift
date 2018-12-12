//
//  ViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/12/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        let logOutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem = logOutButton
    }
    
    @objc func handleLogout() {
        let viewController = LoginViewController()
        self.present(viewController, animated: true, completion: nil)
        
        
    }


}

