//
//  ChatMessageCell.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 1/8/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit
import AVKit

class ChatMessageCell: UICollectionViewCell {
    
    var imageCache: NSCache<AnyObject,AnyObject>?
    var chatLogController: ChatLogController?
    var message: Message?
    static let blueColor: UIColor = UIColor(r: 0, g: 137, b: 249)
    let textView: UITextView = {
       let tv = UITextView()
        tv.text = "Some Text"
        tv.font = UIFont.boldSystemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
       let bubble = UIView()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        bubble.layer.cornerRadius = 16
        bubble.layer.masksToBounds = true
        return bubble
    }()
    
    lazy var playButton: UIButton = {
       let playbutton = UIButton(type: .system)
        playbutton.translatesAutoresizingMaskIntoConstraints = false
        playbutton.addTarget(self, action: #selector(handlePlayVideo), for: .touchUpInside)
        playbutton.setImage(UIImage(named: "play3.png"), for: .normal)
        playbutton.tintColor = .white
        return playbutton
    }()
    
    let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
       profileImageView.layer.cornerRadius = 16
         profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.masksToBounds = true
        return profileImageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let messageImageView = UIImageView()
        messageImageView.layer.cornerRadius = 16
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.layer.masksToBounds = true
        
       messageImageView.isUserInteractionEnabled = true
        messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return messageImageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        bubbleView.addSubview(playButton)

        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 20).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
                textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true

        
            bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchor?.isActive = false
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true

        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

    }
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func handlePlayVideo() {
    
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
             player = AVPlayer(url: url)
             playerLayer = AVPlayerLayer(player: player)
            playerLayer!.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player!.play()
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        
        let imageView = tapGesture.view as? UIImageView
        chatLogController?.performZoomInImageView(imageView!)
    }
    
    func loadMessageImage(_ url: String) {
        
        self.imageCache = nil
        if let imageCache = imageCache {
            if let imageCached = imageCache.object(forKey: url as AnyObject) as? UIImage  {
                self.profileImageView.image = imageCached
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
                            DispatchQueue.main.async {
                                self.messageImageView.image = UIImage(data: data)

                            }
                        }
                    }
                }
                }.resume()
        }
    }
    
     func loadProfileImage(_ url: String) {
        
        self.imageCache = nil
        if let imageCache = imageCache {
            if let imageCached = imageCache.object(forKey: url as AnyObject) as? UIImage  {
                self.profileImageView.image = imageCached
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
                            self.profileImageView.image = UIImage(data: data)
                        }
                    }
                }
                }.resume()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
