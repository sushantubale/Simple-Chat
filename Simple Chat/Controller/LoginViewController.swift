//
//  LoginViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/12/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

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
        return profileImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setuContainerview()
        setupRegisterButton()
        setupProfileImageView()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
    }
    
    func setupRegisterButton() {
        
        view.addSubview(registerButton)
        registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        registerButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -12).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 30)
    }
    
  @objc func register() {
    
    Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self](user, error) in
        
        guard let name = self?.nameTextField.text, let email = self?.emailTextField.text else {return}
        
        if error != nil {
            print("error is \(error)")
            return
        }
        else {

            let ref = Database.database().reference(fromURL: "https://simple-chat-d11ee.firebaseio.com/")
            let values = ["name": name,
                          "email": email]
            let userReference = ref.child("users").child((user?.user.uid)!)
            userReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                if error != nil {
                    print("Error creating user")
                    return
                }
                else {
                    print("successfully user created")
                }
            })
        }
    }

    }
    
    func setupProfileImageView() {
        
        self.view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -12).isActive = true
        
    }
    
    func setuContainerview() {
        
        // container view
        self.view.addSubview(containerView)
        containerView.addSubview(nameTextField)
        containerView.addSubview(nameSeperatorView)
        containerView.addSubview(emailTextField)
        containerView.addSubview(emailSeperatorView)
        containerView.addSubview(passwordTextField)
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        addNameTextfield()
        addEmailTextfield()
        addPasswordTextfield()
    }
    
    func addNameTextfield() {
        
        // name textfield
        nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3).isActive = true
        nameSeperatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func addEmailTextfield() {
        
        // email textfield
        emailTextField.topAnchor.constraint(equalTo: nameSeperatorView.bottomAnchor).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3).isActive = true
        emailSeperatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func addPasswordTextfield() {
        
        // password textfield
        passwordTextField.topAnchor.constraint(equalTo: emailSeperatorView.bottomAnchor).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
