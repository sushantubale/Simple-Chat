//
//  MessageViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/13/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UITableViewController {

    static let cellId = "cell"
    var users = [Users]()
    var imageCache: NSCache<AnyObject,AnyObject>?
    
    lazy var leftBarButton: UIBarButtonItem = {
        let leftBarButton = UIBarButtonItem()
        leftBarButton.title = "Cancel"
        leftBarButton.style = .plain
        leftBarButton.tintColor = .white
        leftBarButton.target = self
        leftBarButton.action = #selector(cancelTapped)
        return leftBarButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: MessageViewController.cellId)
        navigationItem.leftBarButtonItem = leftBarButton
        
        fetchUsers()
    }

    func fetchUsers() {
        
        let ref = Database.database().reference().child("users")
        
        FirebaseHelper.fetchUsers(ref: ref) { [weak self] (snapshot) in
            guard let snapshot = snapshot else {
                print("failed to return users")
                return
            }
            if let dictionary = snapshot.value as? [String: Any] {
                if Auth.auth().currentUser?.uid ==  snapshot.key {
                    return
                }
                let user = Users()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self?.users.append(user)
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        let user = users[indexPath.row]
        chatLogController.chatLogUser = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageViewController.cellId, for: indexPath) as? UserCell
        
        if let cell1 = cell {
            let user = users[indexPath.row]
            cell1.textLabel?.text = user.name
            cell1.detailTextLabel?.text = user.email
            
            if let profileImageURL = user.imageurl {
                self.loadProfileImage(profileImageURL, cell1, tableView)
            }
            return cell1
        }
        return cell!
    }
    
    private func loadProfileImage(_ url: String,_ cell: UserCell,_ tableviewObject: UITableView) {
        
        self.imageCache = nil
        if let imageCache = imageCache {
            if let imageCached = imageCache.object(forKey: url as AnyObject) as? UIImage  {
                cell.profileImageView.image = imageCached
                return
            }
        }
        
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil  {
                    print("Error getting the profile image")
                    return
                }
                
                if let data = data {
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data) {
                            self.imageCache?.setValue(downloadedImage, forKey: url.absoluteString)
                            cell.profileImageView.image = UIImage(data: data)
                        }
                    }
                }
                }.resume()
        }
    }
}
