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
    
    var timer: Timer?
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
    
    lazy var logoutButton: UIBarButtonItem = {
        let logoutButton = UIBarButtonItem()
        logoutButton.title = "Logout"
        logoutButton.style = .plain
        logoutButton.tintColor = . white
        logoutButton.target = self
        logoutButton.action = #selector(handleLogout)
        return logoutButton
    }()
    
    lazy var newMessageButton: UIBarButtonItem = {
        let newMessageButton = UIBarButtonItem()
        newMessageButton.image = UIImage(named: "new_message")
        newMessageButton.style = .plain
        newMessageButton.tintColor = . white
        newMessageButton.target = self
        newMessageButton.action = #selector(newMessageTapped)
        return newMessageButton
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setGradientBackground(colors: [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
            ])

        tableView.register(UserCell.self, forCellReuseIdentifier: MessagesConttoller.cellID)
        view.backgroundColor = .white
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = newMessageButton
    }

    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            let singleMssageRef = Database.database().reference().child("user-messages").child(uid).child(userId)
            singleMssageRef.observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                let messageReferences = Database.database().reference().child("messages").child(messageId)
                messageReferences.observe(.value, with: {[weak self] (snapshot) in
                    
                    self?.addDataToTableView(snapshot: snapshot)
                    }, withCancel: nil)
                
            }, withCancel: nil)
            return
        }, withCancel: nil)
        
        self.deleteMessagesFromOutside()
    }
    
    func addDataToTableView(snapshot: DataSnapshot) {
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let message = Message()
            message.setValuesForKeys(dictionary)
            
            if let chatPartnerId = message.chatPartnerId() {
                self.messagesDictionary[chatPartnerId] = message
            }
            self.handleReloadTableview()
        }
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func handleReloadTableview() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sorted(by: { (message1, message2) -> Bool in
            if let message1Timestamp = message1.timestamp?.intValue, let message2Timestamp = message2.timestamp?.intValue {
                print("message1Timestamp or message2Timestamp is empty")
                return message1Timestamp > message2Timestamp
            }
            return false
        })
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(reloadTableView), userInfo: nil, repeats: false)

    }
    
    func observeMessages() {
        
        let ref = Database.database().reference().child("messages")
        
        FirebaseHelper.childAddedObserver(ref: ref) { [weak self] (snapshot) in
            
            guard let snapshot = snapshot else {
                return
            }
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
                self?.reloadTableView()
            }
        }
    }
    
    private func deleteMessagesFromOutside() {
        
        let ref = Database.database().reference().child("user-messages")
        FirebaseHelper.deleteMessagesFromOutside(ref: ref) { [weak self] (snapshot) in
            guard let snapshot = snapshot else {
                return
            }
            self?.messagesDictionary.removeValue(forKey: snapshot.key)
            self?.handleReloadTableview()
        }
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
                
                if let navBarImageView = self?.navBarImageView, let navBarTitle = self?.navBarTitle  {
                    titleview.addSubview(navBarImageView)
                    titleview.addSubview(navBarTitle)
                    self?.navBarTitle.text = name
                    self?.navBarImageView.leftAnchor.constraint(equalTo: titleview.leftAnchor).isActive = true
                    self?.navBarImageView.centerYAnchor.constraint(equalTo: titleview.centerYAnchor).isActive = true
                    self?.navBarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                    self?.navBarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    
                    self?.navBarTitle.leftAnchor.constraint(equalTo: navBarImageView.leftAnchor, constant: 50).isActive = true
                    self?.navBarTitle.topAnchor.constraint(equalTo: titleview.topAnchor, constant: 10).isActive = true
                }
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
    
    // MARK:- Tableview
    
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let messages = self.messages[indexPath.row]
        if let chatPartnerId = messages.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { [weak self] (error, reference) in
                
                if error != nil {
                    print("error while deleting message = \(String(describing: error))")
                    return
                }
                
                self?.messagesDictionary.removeValue(forKey: chatPartnerId)
                self?.handleReloadTableview()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: MessagesConttoller.cellID, for: indexPath) as? UserCell
        
        if let cell = cell {
            setNameAndProfileImage(cell, indexPath: indexPath)
            if let messageTimestampDoubleVal = messages[indexPath.row].timestamp?.doubleValue {
                let timeStampDate = NSDate(timeIntervalSince1970: messageTimestampDoubleVal)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss"
                cell.timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
                cell.detailTextLabel?.text = messages[indexPath.row].text
                return cell
            }
        }
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
        
        FirebaseHelper.logout()
        
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


extension UINavigationBar {
    func setGradientBackground(colors: [Any]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.locations = [0.0 , 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        var updatedFrame = self.bounds
        updatedFrame.size.height += self.frame.origin.y
        gradient.frame = updatedFrame
        gradient.colors = colors;
        self.setBackgroundImage(self.image(fromLayer: gradient), for: .default)
    }
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
}
