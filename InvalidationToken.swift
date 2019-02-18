//
//  InvalidationToken.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import Foundation

/// The type that all invalidation tokens conform to
public protocol InvalidationTokenType {
    
    /// Indicates if the token is invalid
    var isInvalid : Bool { get }
    
    /// The future will fail with .InvalidationTokenInvalidated when the token invalidates
    var future: Future<NoValue, BrightFuturesError<NoError>> { get }
    
    /// This context executes as long as the token is valid. If the token is invalid, the given blocks are discarded
    func validContext(_ parentContext: @escaping ExecutionContext) -> ExecutionContext
    
}

extension InvalidationTokenType {
    /// Alias of context(parentContext:task:) which uses the default threading model
    /// Due to a limitation of the Swift compiler, we cannot express this with a single method
    public var validContext: ExecutionContext {
        return validContext(DefaultThreadingModel())
    }
    
    public func validContext(_ parentContext: @escaping ExecutionContext = DefaultThreadingModel()) -> ExecutionContext {
        return { task in
            parentContext {
                if !self.isInvalid {
                    task()
                }
            }
        }
    }
}

/// The type that all invalidation tokens that can be manually invalidated conform to
public protocol ManualInvalidationTokenType : InvalidationTokenType {
    /// Invalidates the token
    func invalidate()
}

/// A default invalidation token implementation
public class InvalidationToken : ManualInvalidationTokenType {
    
    public let future = Future<NoValue, BrightFuturesError<NoError>>()
    
    /// Creates a new valid token
    public init() { }
    
    /// Indicates if the token is invalid
    public var isInvalid: Bool {
        return future.isCompleted
    }
    
    /// Invalidates the token
    public func invalidate() {
        future.failure(.invalidationTokenInvalidated)
    }
}
