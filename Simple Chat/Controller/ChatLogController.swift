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

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    lazy var chatLogView = ChatLogView(frame: CGRect(x: 0, y: 0, width:self.view.bounds.width, height: self.view.bounds.height))
    let cellID = "cellID"
    
    var chatLogUser: Users?  {
        didSet {
            navigationItem.title = chatLogUser?.name
            observeLoggedInUserMessages()
        }
    }
    
    var backButtonName: String?
    

    var messages = [Message]()

    // MARK: - View Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(chatLogView)
        setupCollectionViewAttributes()
        chatLogView.uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        chatLogView.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }
    
    private func setupCollectionViewAttributes() {
        
        collectionView.scrollsToTop = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func observeLoggedInUserMessages() {
        
        guard let toId = chatLogUser?.id else {return}
        
        FirebaseHelper.observeMessages(toId: toId,observeLoggedInUserMessages: true) { (snapshot) in
            
            guard let snapshot = snapshot else {
                return
            }
            
            let messageId = snapshot.key
            let userMessageRef = FirebaseHelper.messages.child(messageId)
            self.loadMessages(userMessageRef)
        }
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

    @objc func handleUploadTap() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String, kUTTypeGIF as String]
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedForUrl(videoUrl)
        } else {
            handleImageSelectedForInfo(info)
        }
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
    
    func handleVideoSelectedForUrl(_ videoUrl: URL) {
        
        let fileName = NSUUID().uuidString + ".mov"

        let uploadTask = Storage.storage().reference().child(fileName).putFile(from: videoUrl, metadata: nil) { (responseMetadata, error) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            guard let metadata = responseMetadata, let path = metadata.path else {
                return
            }
            
            self.getDownloadURL(from: path, completion: { (url1, error1) in
                if error1 != nil {
                    return
                }
                
                let thumbnailImage = self.thumbnailImageForVideoUrl(videoUrl: (url1!.absoluteString))
                self.uploadToFirebaseStorageUsingImage(image: thumbnailImage!, isVideo: "true", videoUrl: url1?.absoluteString)
            })
        }
        
        dismiss(animated: true, completion: nil)
        
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completedUnit = snapshot.progress?.completedUnitCount {
                print(completedUnit)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("successfully uploaded image")
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
        do
        {
             let thumbnailcgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailcgImage)

        }catch {
            print(error)
        }
        return nil
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
        
        sendMessage()
    }
    
    func sendMessage(_ imageUrl: String? = nil,_ imageWidth: CGFloat = 0,_ imageHeight: CGFloat = 0,_ videoUrl: String? = nil, isVideo: String? = "false") {
        
        let reference = Database.database().reference().child("messages")
        let childRef = reference.childByAutoId()
        let fromId = Auth.auth().currentUser?.uid
        let toID = chatLogUser?.id
        let timestamp = Date().timeIntervalSince1970
        var values = [String: Any]()
        
        if let messageText = chatLogView.sendMessageTextField.text {
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
                self.chatLogView.sendMessageTextField.text = nil
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
            cell.bubbleWidthAnchor?.constant = estimatedHeightForText(text: messageText).width + 32
            cell.playButton.isHidden = true
        } else if message.imageUrl != nil &&  message.isVideo! == "false" {
            cell.playButton.isHidden = true

           cell.bubbleWidthAnchor?.constant = 200
        } else if message.isVideo! == "true" {
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
            self.chatLogView.sendMessageView.alpha = 0

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
                self.chatLogView.sendMessageView.alpha = 1
            }) { (completed) in
                
                zoomingOutView.removeFromSuperview()
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
