//
//  LoginRegisterView.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/9/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit

class LoginRegisterView: UIView {

    //MARK: Constraints
    var containerViewHeightConstraint: NSLayoutConstraint?
    var nameTextfieldHeightConstraint: NSLayoutConstraint?
    var emailTextfieldHeightConstraint: NSLayoutConstraint?
    var passwordTextfieldHeightConstraint: NSLayoutConstraint?

    //MARK: UIView Elements
    let containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 3
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 24)
        return button
    }()
    
    let nameTextField: UITextField = {
        let nameTextField = UITextField()
        nameTextField.placeholder = "Name"
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.backgroundColor = .white
        nameTextField.textAlignment = .left
        return nameTextField
    }()
    
    let emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.backgroundColor = .white
        emailTextField.textAlignment = .left
        return emailTextField
    }()
    
    let passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.keyboardType = .emailAddress
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.backgroundColor = .white
        passwordTextField.textAlignment = .left
        return passwordTextField
    }()
    
    let nameSeperatorView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        return lineView
    }()
    
    let emailSeperatorView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        return lineView
    }()
    
    let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(named: "profile_placeholder.jpg")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        return profileImageView
    }()
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let loginRegisterSegmentedControl = UISegmentedControl(items: ["Login", "Register"])
        loginRegisterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        loginRegisterSegmentedControl.tintColor = .white
        loginRegisterSegmentedControl.selectedSegmentIndex = 1
        return loginRegisterSegmentedControl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setuContainerview()
        setupRegisterButton()
        setupProfileImageView()
        setupSegmentedControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSegmentedControl() {
        //MARK: segmented control
        self.addSubview(loginRegisterSegmentedControl)
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupRegisterButton() {
        //MARK: register button
        self.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -12).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 30)
    }
    
    
    func setupProfileImageView() {
        //MARK: profile image view
        self.addSubview(profileImageView)
        profileImageView.isUserInteractionEnabled = true
        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -50).isActive = true
    }
    
    
    func setuContainerview() {
        //MARK: container view
        self.addSubview(containerView)
        containerView.addSubview(nameTextField)
        containerView.addSubview(nameSeperatorView)
        containerView.addSubview(emailTextField)
        containerView.addSubview(emailSeperatorView)
        containerView.addSubview(passwordTextField)
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -24).isActive = true
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 150)
        containerViewHeightConstraint?.isActive = true
        
        addNameTextfield()
        addEmailTextfield()
        addPasswordTextfield()
    }
    
    func addNameTextfield() {
        //MARK: name textfield
        nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        nameTextfieldHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3)
        nameTextfieldHeightConstraint?.isActive = true
        nameSeperatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func addEmailTextfield() {
        //MARK: email textfield
        emailTextField.topAnchor.constraint(equalTo: nameSeperatorView.bottomAnchor).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        emailTextfieldHeightConstraint = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3)
        emailTextfieldHeightConstraint?.isActive = true
        emailSeperatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func addPasswordTextfield() {
        //MARK: password textfield
        passwordTextField.topAnchor.constraint(equalTo: emailSeperatorView.bottomAnchor).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        passwordTextfieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3)
        passwordTextfieldHeightConstraint?.isActive = true
    }
}
