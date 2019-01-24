//
//  Message.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 1/3/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    @objc var fromid: String?
    @objc var toid: String?
    @objc var timestamp: NSNumber?
    @objc var text: String?
    @objc var imageUrl: String?
     @objc var imagewidth: NSNumber?
     @objc var imageheight: NSNumber?
    @objc var videoUrl: String?

    

    func chatPartnerId() -> String? {
        return fromid == Auth.auth().currentUser?.uid ? toid : fromid
    }
}
