//
//  ChatLogView.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/7/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit

class ChatLogView: UIView, UITextFieldDelegate {
    
    lazy var sendMessageTextField: UITextField = {
        let sendMessageTextField = UITextField()
        sendMessageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendMessageTextField.backgroundColor = .white
        sendMessageTextField.delegate = self
        sendMessageTextField.placeholder = "Send Message...."
        return sendMessageTextField
    }()
    
    var uploadImageView: UIImageView = UIImageView()
    let sendButton: UIButton = UIButton()

    var sendMessageViewBottomAnchor: NSLayoutConstraint?

    let sendMessageView = UIView()

    lazy var doneBtn: UIBarButtonItem = {
        let doneBtn = UIBarButtonItem()
        doneBtn.title = "Done"
        doneBtn.style = .done
        doneBtn.target = self
        doneBtn.action = #selector(doneButtonAction)
        return doneBtn
    }()
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0,  width: self.frame.size.width, height: 30)
        return toolbar
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        setupKeyboardObservers()

        self.sendMessageTextField.inputAccessoryView = toolbar
        setupSendMessageView()

    }
    
    @objc func doneButtonAction() {
        self.endEditing(true)
    }

    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        sendMessageViewBottomAnchor?.constant = -keyboardSize!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.sendMessageViewBottomAnchor?.constant = 0
            self.layoutIfNeeded()
        }
        
    }
    
    func setupSendMessageView() {
        
        sendMessageView.backgroundColor = .white
        sendMessageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(sendMessageView)
        
        setSendButtonAndTextFieldButton(sendMessageView)
        
        if #available(iOS 11.0, *) {
            let guide = self.safeAreaLayoutGuide
            sendMessageView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            sendMessageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            sendMessageViewBottomAnchor = sendMessageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            sendMessageViewBottomAnchor?.isActive = true
            sendMessageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        else {
            NSLayoutConstraint(item: sendMessageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: sendMessageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
            sendMessageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            sendMessageViewBottomAnchor = sendMessageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            sendMessageViewBottomAnchor?.isActive = true
            
        }
    }
    
    func setSendButtonAndTextFieldButton(_ sendMessageView: UIView) {
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendMessageView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: sendMessageView.rightAnchor, constant: -5).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: sendMessageView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        sendMessageView.addSubview(sendMessageTextField)
        sendMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        sendMessageTextField.centerYAnchor.constraint(equalTo: sendMessageView.centerYAnchor).isActive = true
        sendMessageTextField.heightAnchor.constraint(equalTo: sendMessageView.heightAnchor).isActive = true
        
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
        
        let seperatorView = UIView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(seperatorView)
        seperatorView.backgroundColor = .gray
        seperatorView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        seperatorView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive  = true
        seperatorView.bottomAnchor.constraint(lessThanOrEqualTo: sendMessageView.topAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
