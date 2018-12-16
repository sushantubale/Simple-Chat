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
    
    var containerViewHeightConstraint: NSLayoutConstraint?
    var nameTextfieldHeightConstraint: NSLayoutConstraint?
    var emailTextfieldHeightConstraint: NSLayoutConstraint?
    var passwordTextfieldHeightConstraint: NSLayoutConstraint?

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
    
    lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(named: "profile_placeholder.jpg")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped)))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setuContainerview()
        setupRegisterButton()
        setupProfileImageView()
        setupSegmentedControl()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
    }
    
    func setupSegmentedControl() {
        
        view.addSubview(loginRegisterSegmentedControl)
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginRegisterSegmentedControl.addTarget(self, action: #selector(handleSegmentedControl), for: .valueChanged)
        
    }
    
   @objc func handleSegmentedControl() {
        
        registerButton.setTitle(loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex), for: .normal)
    containerViewHeightConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
    
    nameTextfieldHeightConstraint?.isActive = false
    nameTextfieldHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
    nameTextfieldHeightConstraint?.isActive = true
    
    emailTextfieldHeightConstraint?.isActive = false
    emailTextfieldHeightConstraint = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    emailTextfieldHeightConstraint?.isActive = true

    passwordTextfieldHeightConstraint?.isActive = false
    passwordTextfieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    passwordTextfieldHeightConstraint?.isActive = true

    
    }
    
    func setupRegisterButton() {
        
        view.addSubview(registerButton)
        registerButton.addTarget(self, action: #selector(handelLoginRegister), for: .touchUpInside)
        registerButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -12).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 30)
    }
    
    func handlelogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("error = \(String(describing: error))")
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func handleRegister() {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self](user, error) in
            
            guard let name = self?.nameTextField.text, let email = self?.emailTextField.text else {return}
            
            if error != nil {
                print("error is \(String(describing: error))")
                return
            }
            let imageName = NSUUID().uuidString

            let storageRef = Storage.storage().reference().child(imageName)
            
            if let uploadData = self?.profileImageView.image?.pngData() {
                
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                    
                    if err != nil {
                        print(err!)
                        return
                    }
                    
                    storageRef.downloadURL(completion: { [weak self] (url, err) in
                        if err != nil {
                            print("failed to download url")
                        }
                        
                        let profileImageURL = url?.absoluteString
                        let values = ["name": name,
                                      "email": email,
                                      "imageurl": profileImageURL]
                        guard let uid = user?.user.uid else {return}
                        
                        self?.storeUserData(uid: uid, values: values as [String : AnyObject])
                    })
                })
                
            }
        }
    }
    
    @objc func handelLoginRegister() {
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handlelogin()
        } else {
            handleRegister()
        }
        
    }
    
    private func storeUserData(uid: String, values: [String: AnyObject]) {
        
        let ref = Database.database().reference(fromURL: "https://simple-chat-26867.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { [weak self] (error, reference) in
            if error != nil {
                print("Error creating user")
                return
            }
            
            self?.dismiss(animated: true, completion: nil)
        })
    }
    func setupProfileImageView() {
        
        self.view.addSubview(profileImageView)
        profileImageView.isUserInteractionEnabled = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -50).isActive = true
        
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
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 150)
        containerViewHeightConstraint?.isActive = true
        
        addNameTextfield()
        addEmailTextfield()
        addPasswordTextfield()
    }
    
    func addNameTextfield() {
        
        // name textfield
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
        
        // email textfield
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
        
        // password textfield
        passwordTextField.topAnchor.constraint(equalTo: emailSeperatorView.bottomAnchor).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        passwordTextfieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3)
        passwordTextfieldHeightConstraint?.isActive = true
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

extension LoginViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func handleProfileImageTapped() {
        
        let pickerViewController = UIImagePickerController()
        pickerViewController.delegate = self
        pickerViewController.allowsEditing = true
        present(pickerViewController, animated: true, completion: nil)
    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        print(info)
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        }
        else if let orignalImage = info[.originalImage] as? UIImage {
            selectedImage = orignalImage
        }
        
        DispatchQueue.main.async {
            self.profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
