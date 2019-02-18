//
//  Dispatch+BrightFutures.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    public var context: ExecutionContext {
        return { task in
            self.async(execute: task)
        }
    }
    
    public func asyncValue<T>(_ execute: @escaping () -> T) -> Future<T, NoError> {
        return Future { completion in
            async {
                completion(.success(execute()))
            }
        }
    }
    
    public func asyncResult<T, E>(_ execute: @escaping () -> Result<T, E>) -> Future<T, E> {
        return Future { completion in
            async {
                completion(execute())
            }
        }
    }
    
    public func asyncValueAfter<T>(_ deadline: DispatchTime, execute: @escaping () -> T) -> Future<T, NoError> {
        return Future { completion in
            asyncAfter(deadline: deadline) {
                completion(.success(execute()))
            }
        }
    }
    
}

public extension DispatchSemaphore {
    public var context: ExecutionContext {
        return { task in
            let _ = self.wait(timeout: DispatchTime.distantFuture)
            task()
            self.signal()
        }
    }
}
