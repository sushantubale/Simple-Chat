//
//  ChatLogController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/19/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellID = "cellID"
    var chatLogUser: Users?  {
        didSet {
            navigationItem.title = chatLogUser?.name
            observeLoggedInUserMessages()
        }
    }
    var backButtonName: String?
    lazy var sendMessageTextField: UITextField = {
    let sendMessageTextField = UITextField()
    sendMessageTextField.translatesAutoresizingMaskIntoConstraints = false
    sendMessageTextField.backgroundColor = .white
        sendMessageTextField.delegate = self
        sendMessageTextField.placeholder = "Send Message...."

        return sendMessageTextField
    }()
    
    var messages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        setupSendMessageView()
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    func observeLoggedInUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let loggedInUserMessages = Database.database().reference().child("user-messages").child(uid)
        
        loggedInUserMessages.observe(.childAdded, with: { (snapshot) in
            

            let messageId = snapshot.key
            let userMessageRef = Database.database().reference().child("messages").child(messageId)
            
            self.loadMessages(userMessageRef)

        }, withCancel: nil)
    }
    
    func loadMessages(_ userMessageRef: DatabaseReference) {
        
        userMessageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let messages = Message()
            messages.setValuesForKeys(dictionary)
            if messages.chatPartnerId() == self.chatLogUser?.id {
                self.messages.append(messages)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    func setupSendMessageView() {
        
        let sendMessageView = UIView()
        sendMessageView.backgroundColor = .white
        sendMessageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendMessageView)
        
        setSendButtonAndTextFieldButton(sendMessageView)
        
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            sendMessageView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            sendMessageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            sendMessageView.topAnchor.constraint(equalTo: guide.bottomAnchor, constant: -50).isActive = true
            sendMessageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        else {
            NSLayoutConstraint(item: sendMessageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: sendMessageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: sendMessageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        sendMessageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        }
    }
    
    func setSendButtonAndTextFieldButton(_ sendMessageView: UIView) {
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendMessageView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: sendMessageView.rightAnchor, constant: -5).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: sendMessageView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        sendMessageView.addSubview(sendMessageTextField)
        sendMessageTextField.leftAnchor.constraint(equalTo: sendMessageView.leftAnchor).isActive = true
        sendMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        sendMessageTextField.centerYAnchor.constraint(equalTo: sendMessageView.centerYAnchor).isActive = true
        sendMessageTextField.heightAnchor.constraint(equalTo: sendMessageView.heightAnchor).isActive = true
        
        let seperatorView = UIView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seperatorView)
        seperatorView.backgroundColor = .gray
        seperatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        seperatorView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive  = true
        seperatorView.bottomAnchor.constraint(lessThanOrEqualTo: sendMessageView.topAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func handleSend() {
        
        let reference = Database.database().reference().child("messages")
        let childRef = reference.childByAutoId()
        let fromId = Auth.auth().currentUser?.uid
        let toID = chatLogUser?.id
        let timestamp = Date().timeIntervalSince1970
        
        if let messageText = sendMessageTextField.text {
            let values = ["fromid": fromId as Any, "toid": toID as Any,"text": messageText, "timestamp": timestamp]
            
            childRef.updateChildValues(values) { (error, ref) in
                if error != nil {
                    print(error ?? "")
                    return
                }
                guard let messageId = childRef.key else { return }
                
                let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!).child(messageId)
                userMessagesRef.setValue(1)
                
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID!).child(messageId)
                recipientUserMessagesRef.setValue(1)
                
            }
        }
    }
    
    // MARK: - Collection View Methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        cell.textView.text = messages[indexPath.item].text
        return cell
    }
}

extension ChatLogController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ChatLogController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
