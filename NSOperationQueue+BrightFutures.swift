//
//  NSOperationQueue+BrightFutures.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import Foundation

public extension OperationQueue {
    /// An execution context that operates on the receiver.
    /// Tasks added to the execution context are executed as operations on the queue.
    public var context: ExecutionContext {
        return { [weak self] task in
            self?.addOperation(BlockOperation(block: task))
        }
    }
}
