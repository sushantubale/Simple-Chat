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
    lazy var loginRegisterView: LoginRegisterView = LoginRegisterView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(loginRegisterView)
        loginRegisterView.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped)))
        loginRegisterView.loginRegisterSegmentedControl.addTarget(self, action: #selector(handleSegmentedControl), for: .valueChanged)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handleSegmentedControl() {
        
        if loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            loginRegisterView.profileImageView.isHidden = true
        } else {
            loginRegisterView.profileImageView.isHidden = false
        }

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
    
    @objc func handelLoginRegister() {
        
        if loginRegisterView.loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleRegister() {
        
        guard let emailTextField = loginRegisterView.emailTextField.text, let passwordTextField = loginRegisterView.passwordTextField.text else {
            UIHelper.showSimpleAlert(self, "Error", "Please enter all information to create your account.", .alert)
            return
        }
        
        if passwordTextField.characters.count <= 6 {
            UIHelper.showSimpleAlert(self, "Error", "Please enter the password to be more than 6 characters.", .alert)
            return
        }
        
        FirebaseHelper.handleRegister(emailTextField, passwordTextField) { (user, error) in
            if error != nil {
                UIHelper.showSimpleAlert(self, "Error", (error?.localizedDescription)!, .alert)
            } else {
                self.successHandleRegister(user)
            }
        }
    }
    
    private func successHandleRegister(_ user: AuthDataResult?) {
    
        guard let emailTextField = loginRegisterView.emailTextField.text, let name = loginRegisterView.nameTextField.text else {return}

        let imageName = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child(imageName)
        
        if let compressedImage = loginRegisterView.profileImageView.image?.jpegData(compressionQuality: 0.1) {
            
            storageRef.putData(compressedImage, metadata: nil, completion: { (metadata, err) in
                
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
                                  "email": emailTextField,
                                  "imageurl": profileImageURL]
                    if let uid = user?.user.uid {
                        FirebaseHelper.storeUserData(uid: uid, values: values as [String: AnyObject], completion: { (error, reference) in
                            if error != nil {
                                UIHelper.showSimpleAlert(self!, "Error", (error?.localizedDescription)!, .alert)
                                return
                            }
                            self?.viewController?.fetchUserAndSetNavTitle()
                            self?.dismiss(animated: true, completion: nil)
                        })
                    }
                })
            })
        }
    }
    
    func handleLogin() {
        
        guard let emailTextField = loginRegisterView.emailTextField.text, let passwordTextField = loginRegisterView.passwordTextField.text else {
            return
        }

        if emailTextField.isEmpty || passwordTextField.isEmpty {
            UIHelper.showSimpleAlert(self, "Error", "Please enter all information to login", .alert)
            return
        }
        
        FirebaseHelper.handlelogin(emailTextField, passwordTextField) { (error) in
            if error != nil {
                
                UIHelper.showSimpleAlert(self, "Error", (error?.localizedDescription)!, .alert)
                
            } else {
                self.viewController?.fetchUserAndSetNavTitle()
                self.dismiss(animated: true, completion: nil)
            }
        }
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
