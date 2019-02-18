//
//  Number+BrightFutures.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import Foundation

public extension Int {
    
    public var seconds: DispatchTimeInterval {
        return DispatchTimeInterval.seconds(self)
    }
    
    public var second: DispatchTimeInterval {
        return seconds
    }
    
    public var milliseconds: DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(self)
    }
    
    public var millisecond: DispatchTimeInterval {
        return milliseconds
    }
    
}

public extension DispatchTimeInterval {
    public var fromNow: DispatchTime {
        return DispatchTime.now() + self
    }
}
