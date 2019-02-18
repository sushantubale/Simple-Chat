//
//  Future.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import Foundation

public final class Future<T, E: Error>: Async<Result<T, E>> {
    
    public typealias CompletionCallback = (_ result: Result<T,E>) -> Void
    public typealias SuccessCallback = (T) -> Void
    public typealias FailureCallback = (E) -> Void
    
    public required init() {
        super.init()
    }
    
    public required init(result: Future.Value) {
        super.init(result: result)
    }
    
    public init(value: T, delay: DispatchTimeInterval) {
        super.init(result: Result<T, E>(value: value), delay: delay)
    }
    
    public required init<A: AsyncType>(other: A) where A.Value == Value {
        super.init(other: other)
    }
    
    public required init(result: Value, delay: DispatchTimeInterval) {
        super.init(result: result, delay: delay)
    }
    
    public convenience init(value: T) {
        self.init(result: Result(value: value))
    }
    
    public convenience init(error: E) {
        self.init(result: Result(error: error))
    }
    
    public required init(resolver: (_ result: @escaping (Value) -> Void) -> Void) {
        super.init(resolver: resolver)
    }
    
}

public func materialize<T, E>(_ scope: ((T?, E?) -> Void) -> Void) -> Future<T, E> {
    return Future { complete in
        scope { val, err in
            if let val = val {
                complete(.success(val))
            } else if let err = err {
                complete(.failure(err))
            }
        }
    }
}

public func materialize<T>(_ scope: ((T) -> Void) -> Void) -> Future<T, NoError> {
    return Future { complete in
        scope { val in
            complete(.success(val))
        }
    }
}

public func materialize<E>(_ scope: ((E?) -> Void) -> Void) -> Future<Void, E> {
    return Future { complete in
        scope { err in
            if let err = err {
                complete(.failure(err))
            } else {
                complete(.success(()))
            }
        }
    }
}

public func ?? <T, E>(_ lhs: Future<T, E>, rhs: @autoclosure @escaping  () -> T) -> Future<T, NoError> {
    return lhs.recover(context: DefaultThreadingModel(), task: { _ in
        return rhs()
    })
}

public func ?? <T, E, E1>(_ lhs: Future<T, E>, rhs: @autoclosure @escaping () -> Future<T, E1>) -> Future<T, E1> {
    return lhs.recoverWith(context: DefaultThreadingModel(), task: { _ in
        return rhs()
    })
}

public enum NoValue { }
