//
//  ChatMessageCell.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 1/8/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    var imageCache: NSCache<AnyObject,AnyObject>?

    static let blueColor: UIColor = UIColor(r: 0, g: 137, b: 249)
    let textView: UITextView = {
       let tv = UITextView()
        tv.text = "Some Text"
        tv.font = UIFont.boldSystemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.textColor = .white
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
    
    let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
       profileImageView.layer.cornerRadius = 16
         profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.masksToBounds = true
        profileImageView.image = UIImage(named: "multiple_train.png")
        return profileImageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(bubbleView)
        addSubview(textView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
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
