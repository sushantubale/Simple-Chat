//
//  Async.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import Foundation

open class Async<Value>: AsyncType {
    
    typealias CompletionCallback = (Value) -> Void
    
    public fileprivate(set) var result: Value? {
        willSet {
            assert(result == nil)
        }
        
        didSet {
            assert(result != nil)
            runCallbacks()
        }
    }
    
    fileprivate let queue = DispatchQueue(label: "Internal Async Queue")
    
    fileprivate let callbackExecutionSemaphore = DispatchSemaphore(value: 1);
    fileprivate var callbacks = [CompletionCallback]()
    
    public required init() {
        
    }
    
    public required init(result: Value) {
        self.result = result
    }
    
    public required init(result: Value, delay: DispatchTimeInterval) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) {
            self.complete(result)
        }
    }
    
    public required init<A: AsyncType>(other: A) where A.Value == Value {
        completeWith(other)
    }
    
    public required init(resolver: (_ result: @escaping (Value) -> Void) -> Void) {
        resolver { val in
            self.complete(val)
        }
    }
    
    private func runCallbacks() {
        guard let result = self.result else {
            assert(false, "can only run callbacks on a completed future")
            return
        }
        
        for callback in self.callbacks {
            callback(result)
        }
        
        self.callbacks.removeAll()
    }
    
    @discardableResult
    open func onComplete(_ context: @escaping ExecutionContext = DefaultThreadingModel(), callback: @escaping (Value) -> Void) -> Self {
        let wrappedCallback : (Value) -> Void = { [weak self] value in
            let s = self
            context {
                s?.callbackExecutionSemaphore.context {
                    callback(value)
                }
                return
            }
        }
        
        queue.sync {
            if let value = self.result {
                wrappedCallback(value)
            } else {
                self.callbacks.append(wrappedCallback)
                
            }
        }
        
        return self
    }
    
}

extension Async: MutableAsyncType {
    @discardableResult
    func tryComplete(_ value: Value) -> Bool{
        return queue.sync {
            guard self.result == nil else {
                return false
            }
            
            self.result = value
            return true
        }
    }
}

extension Async: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "Async<\(Value.self)>(\(String(describing: self.result)))"
    }
    
    public var debugDescription: String {
        return description
    }
}
