//
//  ChatLogController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/19/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

protocol sendARVideos: class {
    func sendARVideo(_ dataURL: URL,_ object: ChatLogController,_ chatObject: Users)
}

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    let sendMessageView = UIView()
    weak var chatLogDelegate: sendARVideos!
    
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
    
    lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30)
        toolbar.sizeToFit()
        return toolbar
    }()
    
    lazy var doneBtn: UIBarButtonItem = {
        let doneBtn = UIBarButtonItem()
        doneBtn.title = "Done"
        doneBtn.style = .done
        doneBtn.target = self
        doneBtn.action = #selector(doneButtonAction)
        return doneBtn
    }()
    
    var messages = [Message]()
    var sendMessageViewBottomAnchor: NSLayoutConstraint?

    // MARK: - View Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViewSettings()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneBtn], animated: false)
        self.sendMessageTextField.inputAccessoryView = toolBar
        setupSendMessageView()
        setupKeyboardObservers()
    }
    
    private func setupCollectionViewSettings() {
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    deinit {
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
        
        FirebaseHelper.childAddedObserver(ref: loggedInUserMessages) { [weak self] (snapshot) in
            
            guard let snapshot = snapshot else {
                print("ChatLogController observeLoggedInUserMessage error")
                return
            }
            
            let messageId = snapshot.key
            let userMessageRef = Database.database().reference().child("messages").child(messageId)
            self?.loadMessages(userMessageRef)
        }
    }
    
    func loadMessages(_ userMessageRef: DatabaseReference) {
        
        FirebaseHelper.observeSingleEventOfValue(userMessageRef: userMessageRef) { (snapshot) in
            
            guard let snapshot = snapshot, let dictionary = snapshot.value as? [String: AnyObject] else {
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
        }
    }
    
    func setupSendMessageView() {
        
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
        } else {
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
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))

        let seperatorView = UIView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seperatorView)
        seperatorView.backgroundColor = .gray
        seperatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        seperatorView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive  = true
        seperatorView.bottomAnchor.constraint(lessThanOrEqualTo: sendMessageView.topAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    @objc func handleUploadTap() {
        
        let alert = UIAlertController(title: "Please Select an Option", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Send Photos or Videos", style: .default , handler:{ (UIAlertAction)in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String, kUTTypeGIF as String]
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)

        }))
        
        alert.addAction(UIAlertAction(title: "Record and Send AR", style: .default , handler:{ (UIAlertAction)in
            let newViewController = NewViewController()
            newViewController.users = self.chatLogUser
            let navController = UINavigationController(rootViewController: newViewController)
            self.present(navController, animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedForUrl(videoUrl)
        } else {
            handleImageSelectedForInfo(info)
        }
    }
    
    func sendARVideo(_ dataURL: URL,_ object: ChatLogController,_ chatObject: Users) {
        handleVideoSelectedForUrlForAR(dataURL, object, chatObject)
    }

    func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageForPicker: UIImage? = UIImage()
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageForPicker = editedImage
            
        } else if let orignalImage = info[.originalImage] as? UIImage {
            selectedImageForPicker = orignalImage
        }
        
        if let selectedImage = selectedImageForPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func handleVideoSelectedForUrlForAR(_ videoUrl: URL,_ selfObject: ChatLogController? = nil,_ users: Users? = nil) {
        guard let selfObject = selfObject else {
            print("self is nil")
            return
        }
        
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child(fileName)
        
        FirebaseHelper.putFiletoFirebase(uploadTask: uploadTask, videoUrl: videoUrl) { [weak self] (responseMetadata, error) in
            
            guard let metadata = responseMetadata, let path = metadata.path else {
                return
            }
            
            if error != nil {
                print(error as Any)
                return
            }
            
            selfObject.getDownloadURL(from: path, completion: { (url1, error1) in
                if error1 != nil {
                    return
                }
                guard let url1 = url1 else {
                    return
                }
                
                if let thumbnailImage = selfObject.thumbnailImageForVideoUrl(videoUrl: (url1.absoluteString)) {
                    selfObject.uploadToFirebaseStorageUsingImageForAR(image: thumbnailImage, videoUrl: url1.absoluteString, selfObject, users)
                }
            })
            selfObject.dismiss(animated: true, completion: nil)
        }

    }
    
    func handleVideoSelectedForUrl(_ videoUrl: URL) {
        
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child(fileName)
        
       FirebaseHelper.putFiletoFirebase(uploadTask: uploadTask, videoUrl: videoUrl) { [weak self] (responseMetadata, error) in
            
            guard let metadata = responseMetadata, let path = metadata.path else {
                return
            }

            if error != nil {
                print(error as Any)
                return
            }
            
            self?.getDownloadURL(from: path, completion: { (url1, error1) in
                if error1 != nil {
                    return
                }
                guard let url1 = url1 else {
                    return
                }

                if let thumbnailImage = self?.thumbnailImageForVideoUrl(videoUrl: (url1.absoluteString)) {
                    self?.uploadToFirebaseStorageUsingImage(image: thumbnailImage, isVideo: "true", videoUrl: url1.absoluteString)
                }
            })
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func getDownloadURL(from path: String, completion: @escaping (URL?, Error?) -> Void) {
        
        Storage.storage().reference().child(path).downloadURL { (url, err) in
            if err != nil {
                completion(nil, err)
            }
            else {
                completion(url, nil)
            }
        }
    }

   private func thumbnailImageForVideoUrl(videoUrl: String) -> UIImage? {
        let assest = AVAsset(url: URL(string: videoUrl)!)
        let imageGenerator = AVAssetImageGenerator(asset: assest)
        do {
             let thumbnailcgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
                return UIImage(cgImage: thumbnailcgImage)
        }catch {
            print(error)
        }
        return nil
    }

    private func uploadToFirebaseStorageUsingImageForAR(image: UIImage, videoUrl: String? = nil,_ selfObject: ChatLogController? = nil,_ users: Users? = nil) {
        
        guard let selfObject = selfObject else {
            return
        }
        
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messages_images").child(imageName)
        let messageImage = image.jpegData(compressionQuality: 0.2)
        
        ref.putData(messageImage!, metadata: nil) { (metadata, error) in
            if error != nil {
                
                print("error while downoading image", error as Any)
                return
            }
            
            ref.downloadURL(completion: { (url, err) in
                if err != nil {
                    print("failed to download url")
                }
                
                let profileImageURL = url?.absoluteString
                selfObject.sendMessageForAR(profileImageURL, image.size.width, image.size.height, videoUrl, isVideo: "true", selfObject, users)
            })
        }

    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, isVideo: String? = "false", videoUrl: String? = nil) {
        
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messages_images").child(imageName)
        let messageImage = image.jpegData(compressionQuality: 0.2)
        
        ref.putData(messageImage!, metadata: nil) { (metadata, error) in
            if error != nil {
                
                print("error while downoading image", error as Any)
                return
            }
            
            ref.downloadURL(completion: { [weak self] (url, err) in
                if err != nil {
                    print("failed to download url")
                }
                
                let profileImageURL = url?.absoluteString
                if isVideo == "true" {
                    self?.sendMessage(profileImageURL, image.size.width, image.size.height, videoUrl, isVideo: "true")
                }
                else {
                    self?.sendMessage(profileImageURL, image.size.width, image.size.height, nil)
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func handleSend() {
        guard let messageText = self.sendMessageTextField.text else {
        
            return
        }
        sendMessage()
    }
    
    func sendMessageForAR(_ imageUrl: String? = nil,_ imageWidth: CGFloat = 0,_ imageHeight: CGFloat = 0,_ videoUrl: String? = nil, isVideo: String? = "false",_ selfObject: ChatLogController? = nil,_ users: Users? = nil) {
        let reference = Database.database().reference().child("messages")
        let childRef = reference.childByAutoId()
        let fromId = Auth.auth().currentUser?.uid
        let toID = users?.id
        let timestamp = Date().timeIntervalSince1970
        var values = [String: Any]()
        
        if let messageText = sendMessageTextField.text {
            if imageUrl != nil && isVideo == "false" {
                values = ["fromid": fromId as Any, "toid": toID as Any, "timestamp": timestamp, "imageUrl": imageUrl!, "imagewidth": imageWidth, "imageheight": imageHeight, "isVideo": "false"]
            }
            else {
                if videoUrl != nil && isVideo == "true" {
                    values = ["fromid": fromId as Any, "toid": toID as Any, "timestamp": timestamp, "videoUrl": videoUrl!,"imageUrl": imageUrl!, "imagewidth": imageWidth, "imageheight": imageHeight, "isVideo": "true"]
                }
                else {
                    values = ["fromid": fromId as Any, "toid": toID as Any,"text": messageText, "timestamp": timestamp, "isVideo": "false"]
                }
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
                selfObject!.sendMessageTextField.text = nil
            }
        }

        
    }
    
    func sendMessage(_ imageUrl: String? = nil,_ imageWidth: CGFloat = 0,_ imageHeight: CGFloat = 0,_ videoUrl: String? = nil, isVideo: String? = "false") {
        
        let reference = Database.database().reference().child("messages")
        let childRef = reference.childByAutoId()
        let fromId = Auth.auth().currentUser?.uid
        let toID = chatLogUser?.id
        let timestamp = Date().timeIntervalSince1970
        var values = [String: Any]()
        
        if let messageText = sendMessageTextField.text {
            if imageUrl != nil && isVideo == "false" {
                values = ["fromid": fromId as Any, "toid": toID as Any, "timestamp": timestamp, "imageUrl": imageUrl!, "imagewidth": imageWidth, "imageheight": imageHeight, "isVideo": "false"]
            }
            else {
                if videoUrl != nil && isVideo == "true" {
                    values = ["fromid": fromId as Any, "toid": toID as Any, "timestamp": timestamp, "videoUrl": videoUrl!,"imageUrl": imageUrl!, "imagewidth": imageWidth, "imageheight": imageHeight, "isVideo": "true"]
                }
                else {
             values = ["fromid": fromId as Any, "toid": toID as Any,"text": messageText, "timestamp": timestamp, "isVideo": "false"]
                }
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
        
        let messages = self.messages[indexPath.item]
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
        cell.message = message
        cell.chatLogController = self
        setupCell(message: message, cell: cell)
        
        cell.textView.text = message.text
        if let messageText = message.text {
            cell.videoZoomInView.isHidden = true
            cell.bubbleWidthAnchor?.constant = estimatedHeightForText(text: messageText).width + 32
            cell.playButton.isHidden = true
        } else if message.imageUrl != nil &&  message.isVideo! == "false" {
            cell.playButton.isHidden = true
            cell.videoZoomInView.isHidden = true
           cell.bubbleWidthAnchor?.constant = 200
        } else if message.isVideo! == "true" {
            cell.videoZoomInView.isHidden = true
            cell.playButton.isHidden = false
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
            cell.textView.isHidden = true

        }
        else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }
        
        if let videoUrl = message.videoUrl {
            cell.loadMessageImage(videoUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
            cell.textView.isHidden = true

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
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    
    func runVideosInFullScreen(name: String, type: String, url: URL) {
        let videoViewController = VideoViewController()
        videoViewController.url = url
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(videoViewController, animated: true)
        }
    }

    func performZoomInImageView(_ startingImageView: UIImageView) {
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        let keyWindow = UIApplication.shared.keyWindow
        self.blackBackgroundView = UIView(frame: (keyWindow?.frame)!)
        self.blackBackgroundView!.backgroundColor = .black
        self.blackBackgroundView!.alpha = 0
        keyWindow?.addSubview(self.blackBackgroundView!)
        
        keyWindow?.addSubview(zoomingImageView)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            self.blackBackgroundView!.alpha = 1
            self.sendMessageView.alpha = 0

            let height = CGFloat((self.startingFrame?.height)!) / CGFloat((self.startingFrame?.width)!) * CGFloat((keyWindow?.frame.width)!)

            zoomingImageView.frame = CGRect(x: 0, y: 0, width: (keyWindow?.frame.width)!, height: height)

            zoomingImageView.center = (keyWindow?.center)!

        }, completion: nil)
    }

    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomingOutView = tapGesture.view {
            zoomingOutView.layer.cornerRadius = 16
            zoomingOutView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                zoomingOutView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.sendMessageView.alpha = 1
            }) { (completed) in
                
                zoomingOutView.removeFromSuperview()
            }
        }
    }
}

extension ChatLogController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ChatLogController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
