//
//  UIHelper.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/19/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit

class UIHelper: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    static func showAlert(msg : String , viewController : UIViewController) -> Void{
        
        let alertController = UIAlertController(title: "Alert!", message: msg, preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        viewController.present(alertController, animated: true, completion: nil)// error is being generated here
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
