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
    
    var viewController: MessagesConttoller? = nil
    
    lazy var loginRegisterView = LoginRegisterView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(loginRegisterView)
        setupActions()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
    }
    
    func setupActions() {
        loginRegisterView.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped)))
        loginRegisterView.loginRegisterSegmentedControl.addTarget(self, action: #selector(handleSegmentedControl), for: .valueChanged)
        loginRegisterView.registerButton.addTarget(self, action: #selector(handelLoginRegister), for: .touchUpInside)
    }
    
    @objc func handleSegmentedControl() {
        loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? (loginRegisterView.profileImageView.isHidden = true) : (loginRegisterView.profileImageView.isHidden = false)

        loginRegisterView.registerButton.setTitle(loginRegisterView.loginRegisterSegmentedControl.titleForSegment(at: loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex), for: .normal)
        loginRegisterView.containerViewHeightConstraint?.constant = loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        loginRegisterView.nameTextfieldHeightConstraint?.isActive = false
        loginRegisterView.nameTextfieldHeightConstraint = loginRegisterView.nameTextField.heightAnchor.constraint(equalTo: loginRegisterView.containerView.heightAnchor, multiplier: loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        loginRegisterView.nameTextfieldHeightConstraint?.isActive = true
        loginRegisterView.emailTextfieldHeightConstraint?.isActive = false
        loginRegisterView.emailTextfieldHeightConstraint = loginRegisterView.emailTextField.heightAnchor.constraint(equalTo: loginRegisterView.containerView.heightAnchor, multiplier: loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        loginRegisterView.emailTextfieldHeightConstraint?.isActive = true
        loginRegisterView.passwordTextfieldHeightConstraint?.isActive = false
        loginRegisterView.passwordTextfieldHeightConstraint = loginRegisterView.passwordTextField.heightAnchor.constraint(equalTo: loginRegisterView.containerView.heightAnchor, multiplier: loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        loginRegisterView.passwordTextfieldHeightConstraint?.isActive = true
    }
    
    func handlelogin() {
        
        guard let email = loginRegisterView.emailTextField.text, let password = loginRegisterView.passwordTextField.text else {return}
        
        FirebaseHelper.handleLogin(email: email, password: password) { (user, error) in
            
            if let error = error {
                UIHelper.showAlert(msg: error.localizedDescription, viewController: self)
                print("error = \(String(describing: error))")
            }
            else {
                self.viewController?.fetchUserAndSetNavTitle()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func handleRegister() {
        
        guard let email = loginRegisterView.emailTextField.text, let password = loginRegisterView.passwordTextField.text, let name = loginRegisterView.nameTextField.text else {
            return
        }
        
        FirebaseHelper.handleRegister(email: email, password: password, name: name) { [weak self] (user, error) in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child(imageName)
            
            if let compressedImage = self?.loginRegisterView.profileImageView.image?.jpegData(compressionQuality: 0.1) {
                
                FirebaseHelper.storeData(compressedImage: compressedImage, storageRef: storageRef, completion: { [weak self] (metadata, error) in
                    if error != nil {
                        UIHelper.showAlert(msg: error.debugDescription, viewController: self!)
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
        
        if loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
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
                UIHelper.showAlert(msg: error.debugDescription, viewController: self!)
                print("Error creating user")
                return
            }
            self?.viewController?.fetchUserAndSetNavTitle()
            self?.dismiss(animated: true, completion: nil)
        })
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
            self.loginRegisterView.profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}

