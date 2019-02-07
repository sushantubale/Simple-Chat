//
//  UIHelper.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/6/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit

class UIHelper: UIViewController {
    
    static func showSimpleAlert(_ onViewController: UIViewController,_ title: String,_ message: String,_ preferredStyle: UIAlertController.Style) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        
        onViewController.present(alertController, animated: true, completion: nil)
    }

    
}

