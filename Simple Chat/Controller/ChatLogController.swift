//
//  ChatLogController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/19/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    var sendMessageViewBottomAnchor: NSLayoutConstraint?

    // MARK: - View Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.keyboardDismissMode = .interactive
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()

        self.sendMessageTextField.inputAccessoryView = toolbar
        
        setupSendMessageView()
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        
        setupKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    @objc func doneButtonAction() {
        self.view.endEditing(true)

    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        self.collectionView.scrollsToTop = true
        sendMessageViewBottomAnchor?.constant = -keyboardSize!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
}
    
    @objc func keyboardWillHide(notification: NSNotification) {

        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue

        UIView.animate(withDuration: keyboardDuration!) {
            self.sendMessageViewBottomAnchor?.constant = 0
            self.view.layoutIfNeeded()
        }

    }
    
    func observeLoggedInUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = chatLogUser?.id else {
            return
        }
        
        let loggedInUserMessages = Database.database().reference().child("user-messages").child(uid).child(toId)
        
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
                self.messages.append(messages)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexpath, at: UICollectionView.ScrollPosition.bottom, animated: true)
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
           sendMessageViewBottomAnchor = sendMessageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            sendMessageViewBottomAnchor?.isActive = true
            sendMessageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        else {
            NSLayoutConstraint(item: sendMessageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: sendMessageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        sendMessageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            sendMessageViewBottomAnchor = sendMessageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            sendMessageViewBottomAnchor?.isActive = true

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
        sendMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        sendMessageTextField.centerYAnchor.constraint(equalTo: sendMessageView.centerYAnchor).isActive = true
        sendMessageTextField.heightAnchor.constraint(equalTo: sendMessageView.heightAnchor).isActive = true
        
        let uploadImageView = UIImageView()
       uploadImageView.layer.cornerRadius = 15
       uploadImageView.layer.masksToBounds = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.image = UIImage(named: "uploadImage.png")
        sendMessageView.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: sendMessageView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: sendMessageView.centerYAnchor).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        sendMessageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 16).isActive = true

       uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSendImage)))

        let seperatorView = UIView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seperatorView)
        seperatorView.backgroundColor = .gray
        seperatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        seperatorView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive  = true
        seperatorView.bottomAnchor.constraint(lessThanOrEqualTo: sendMessageView.topAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    @objc func handleSendImage() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageForPicker: UIImage? = UIImage()
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageForPicker = editedImage
            
        } else if let orignalImage = info[.originalImage] as? UIImage {
        selectedImageForPicker = orignalImage
    }
        
        if let selectedImage = selectedImageForPicker {
            uploadImageToStorage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    
    }
    
    private func uploadImageToStorage(image: UIImage) {
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("messages_images").child(imageName)
        let messageImage = image.jpegData(compressionQuality: 0.1)
        
        storageRef.putData(messageImage!, metadata: nil) { (metadata, error) in
            if error != nil {
                
                print("error while downoading image", error)
                return
            }
            
            storageRef.downloadURL(completion: { [weak self] (url, err) in
                if err != nil {
                    print("failed to download url")
                }
                
                let profileImageURL = url?.absoluteString

                self?.sendMessage(profileImageURL, image.size.width, image.size.height)
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func handleSend() {
        
        sendMessage()
    }
    
    func sendMessage(_ imageUrl: String? = nil,_ imageWidth: CGFloat = 0,_ imageHeight: CGFloat = 0) {
        
        let reference = Database.database().reference().child("messages")
        let childRef = reference.childByAutoId()
        let fromId = Auth.auth().currentUser?.uid
        let toID = chatLogUser?.id
        let timestamp = Date().timeIntervalSince1970
        var values = [String: Any]()
        
        if let messageText = sendMessageTextField.text {
            if imageUrl != nil {
                values = ["fromid": fromId as Any, "toid": toID as Any, "timestamp": timestamp, "imageUrl": imageUrl!, "imagewidth": imageWidth, "imageheight": imageHeight]
            }
            else {
             values = ["fromid": fromId as Any, "toid": toID as Any,"text": messageText, "timestamp": timestamp]
            }
            
            childRef.updateChildValues(values) { (error, ref) in
                if error != nil {
                    print(error ?? "")
                    return
                }
                guard let messageId = childRef.key else { return }
                
                let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!).child(toID!)
                userMessagesRef.updateChildValues([messageId: 1])
                
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID!).child(fromId!)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
                self.sendMessageTextField.text = nil
            }
        }
    }
    // MARK: - Collection View Methods
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        var messages = self.messages[indexPath.item]
        if let text = messages.text {
            height = estimatedHeightForText(text: text).height + 40
        } else if let imageWidth = messages.imagewidth?.floatValue, let imageHeight = messages.imageheight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let mainScreenWidth = UIScreen.main.bounds.width
        return CGSize(width: mainScreenWidth, height: height)

    }
    
    private func estimatedHeightForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedString.Key: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        setupCell(message: message, cell: cell)
        
        cell.textView.text = message.text
        if let messageText = message.text {
            cell.bubbleWidthAnchor?.constant = estimatedHeightForText(text: messageText).width + 32
        } else if message.imageUrl != nil {
           cell.bubbleWidthAnchor?.constant = 200
        }
        return cell
    }
    
    func setupCell(message: Message, cell: ChatMessageCell) {
        
        if let profileImage = self.chatLogUser?.imageurl {
            cell.loadProfileImage(profileImage)
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.loadMessageImage(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear

        }
        else {
            cell.messageImageView.isHidden = true
        }
        
        if message.fromid == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true

        }
        else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            DispatchQueue.main.async {
                cell.bubbleViewRightAnchor?.isActive = false
                cell.bubbleViewLeftAnchor?.isActive = true
                cell.profileImageView.isHidden = false
            }
        }
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
