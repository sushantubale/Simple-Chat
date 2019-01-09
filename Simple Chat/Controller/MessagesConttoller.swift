//
//  ViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/12/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class MessagesConttoller: UITableViewController {
    
    var imageCache: NSCache<AnyObject,AnyObject>?
    var messagesDictionary = [String: Message]()
    static let cellID = "cell"
    var messages = [Message]()
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
        tableView.register(UserCell.self, forCellReuseIdentifier: MessagesConttoller.cellID)
        view.backgroundColor = .white
        let logOutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem = logOutButton
        let newMessageButton = UIBarButtonItem(image: UIImage(named: "new_message"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(newMessageTapped))
        navigationItem.rightBarButtonItem = newMessageButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageReferences = Database.database().reference().child("messages").child(messageId)
            messageReferences.observe(.value, with: {[weak self] (snapshot) in
                
                self?.addDataToTableView(snapshot: snapshot)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func addDataToTableView(snapshot: DataSnapshot) {
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let message = Message()
            message.setValuesForKeys(dictionary)
            
            if let toid = message.toid {
                self.messagesDictionary[toid] = message
            }
                self.messages = Array(self.messagesDictionary.values)
            
            
            self.messages.sorted(by: { (message1, message2) -> Bool in
                return message2.timestamp!.intValue > message1.timestamp!.intValue
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func observeMessages() {
        
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: {[weak self] (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if let toid = message.toid {
                    self?.messagesDictionary[toid] = message
                }
                if let values = self?.messagesDictionary.values {
                    self?.messages = Array(values)
                }
                
                self?.messages.sorted(by: { (message1, message2) -> Bool in
                    return message2.timestamp!.intValue > message1.timestamp!.intValue
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }, withCancel: nil)
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
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        self.observeUserMessages()

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
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messages1 = messages[indexPath.row].chatPartnerId()
        
        guard let chatPartnerId = messages1 else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observe(.value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let chatUser = Users()
            chatUser.id = snapshot.key
            chatUser.setValuesForKeys(dictionary)
            self.showChatLogcontroller(user: chatUser)
            
        }, withCancel: nil)

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: MessagesConttoller.cellID, for: indexPath) as? UserCell
        if let cell = cell {
            setNameAndProfileImage(cell, indexPath: indexPath)
        }
            let timeStampDate = NSDate(timeIntervalSince1970: (messages[indexPath.row].timestamp?.doubleValue)!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss"
            cell?.timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
            cell?.detailTextLabel?.text = messages[indexPath.row].text
            return cell!

        }
    

    private func setNameAndProfileImage(_ cell: UserCell, indexPath: IndexPath) {
        
    if let id = messages[indexPath.row].chatPartnerId() {
        let ref = Database.database().reference().child("users").child(id)
        ref.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                cell.textLabel?.text = dictionary["name"] as? String
                if let profileImageURL = dictionary["imageurl"] {
                    self.loadProfileImage(profileImageURL as! String, cell, self.tableView)
                }
            }
        }, withCancel: nil)

}
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
    
    func showChatLogcontroller(user: Users) {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.chatLogUser = user
    navigationController?.pushViewController(chatLogController, animated: true)
    }
}
