//
//  Message.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 1/3/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit

class Message: NSObject {

    @objc var fromid: String?
    @objc var toid: String?
    @objc var timestamp: NSNumber?
    @objc var text: String?
}
