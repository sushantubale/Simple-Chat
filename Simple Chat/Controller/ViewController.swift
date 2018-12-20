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
    
    let navBarImageView:UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 20
        image.layer.masksToBounds = true
        return image
    }()
    
    let  navBarTitle: UILabel = {
      let navBarTitle = UILabel()
        navBarTitle.translatesAutoresizingMaskIntoConstraints = false
        return navBarTitle
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // https://simple-chat-d11ee.firebaseio.com/
        
        view.backgroundColor = .white
        let logOutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem = logOutButton
        let newMessageButton = UIBarButtonItem(image: UIImage(named: "new_message"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(newMessageTapped))
        navigationItem.rightBarButtonItem = newMessageButton
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            fetchUserAndSetNavTitle()
        }
    }
    
    func fetchUserAndSetNavTitle() {
        
        guard  let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let name = dictionary["name"] as? String
                self?.getProfileImage(dictionary["imageurl"] as! String , completionHandler: { [weak self] (image) -> (Void) in
                    self?.navBarImageView.image = image
                })
                
                let titleview = UIView()
                titleview.layer.cornerRadius = 20
                titleview.layer.masksToBounds = true
                self?.navigationItem.titleView = titleview
                titleview.backgroundColor = .white
                titleview.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
                titleview.addSubview((self?.navBarImageView)!)
                titleview.addSubview((self?.navBarTitle)!)
                self?.navBarTitle.text = name
                self?.navBarImageView.leftAnchor.constraint(equalTo: titleview.leftAnchor).isActive = true
                self?.navBarImageView.centerYAnchor.constraint(equalTo: titleview.centerYAnchor).isActive = true
                self?.navBarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                self?.navBarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                
                self?.navBarTitle.leftAnchor.constraint(equalTo: (self?.navBarImageView.leftAnchor)!, constant: 50).isActive = true
                self?.navBarTitle.topAnchor.constraint(equalTo: titleview.topAnchor, constant: 10).isActive = true
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self?.openChatLogController))
                titleview.addGestureRecognizer(tap)
            }
        }
    }
    
    @objc func openChatLogController() {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    func getProfileImage(_ url: String, completionHandler: @escaping (UIImage) -> (Void)) {
        
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if error != nil  {
                    print("Error getting the profile image")
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
                        
                        if let downloadedImage = UIImage(data: data) {
                            completionHandler(downloadedImage)
                        }
                        
                    }
                }
                }.resume()
        }
    }
    
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()

        } catch {print(error)}
        
        let viewController = LoginViewController()
        viewController.viewController = self
        self.present(viewController, animated: true, completion: nil)
        
        
    }
    
    
}
