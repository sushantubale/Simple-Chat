//
//  Error.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit

extension SceneKitVideoRecorder {
    public enum ErrorCode: Int {
        case notReady = 0
        case zeroFrames = 1
        case assetExport = 2
        case recorderBusy = 3
        case unknown = 4
    }
}
