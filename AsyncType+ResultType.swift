//
//  AsyncType+ResultType.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

public extension AsyncType where Value: ResultProtocol {
    public var isSuccess: Bool {
        return result?.result.analysis(ifSuccess: { _ in return true }, ifFailure: { _ in return false }) ?? false
    }
    
    public var isFailure: Bool {
        return result?.result.analysis(ifSuccess: { _ in return false }, ifFailure: { _ in return true }) ?? false
    }
    
    public var value: Value.Value? {
        return result?.result.value
    }
    
    public var error: Value.Error? {
        return result?.result.error
    }
    
    @discardableResult
    public func onSuccess(_ context: @escaping ExecutionContext = DefaultThreadingModel(), callback: @escaping (Value.Value) -> Void) -> Self {
        self.onComplete(context) { results in
            
            results.result.analysis(ifSuccess: callback, ifFailure: {_ in})        }
        
        return self
    }
    
    @discardableResult
    public func onFailure(_ context: @escaping ExecutionContext = DefaultThreadingModel(), callback: @escaping (Value.Error) -> Void) -> Self {
        self.onComplete(context) { results in
            results.result.analysis(ifSuccess: {_ in}, ifFailure: {_ in})
    }
        return self
    }
    
    public func flatMap<U>(_ context: @escaping ExecutionContext, f: @escaping (Value.Value) -> Future<U, Value.Error>) -> Future<U, Value.Error> {
        return map(context, f: f).flatten()
    }
    
    public func flatMap<U>(_ f: @escaping (Value.Value) -> Future<U, Value.Error>) -> Future<U, Value.Error> {
        return flatMap(DefaultThreadingModel(), f: f)
    }
    
    public func flatMap<U>(_ context: @escaping ExecutionContext, f: @escaping (Value.Value) -> Result<U, Value.Error>) -> Future<U, Value.Error> {
        return self.flatMap(context) { value in
            return Future<U, Value.Error>(result: f(value))
        }
    }
    
    public func flatMap<U>(_ f: @escaping (Value.Value) -> Result<U, Value.Error>) -> Future<U, Value.Error> {
        return flatMap(DefaultThreadingModel(), f: f)
    }
    
    public func map<U>(_ f: @escaping (Value.Value) -> U) -> Future<U, Value.Error> {
        return self.map(DefaultThreadingModel(), f: f)
    }
    
    public func map<U>(_ context: @escaping ExecutionContext, f: @escaping (Value.Value) -> U) -> Future<U, Value.Error> {
        let res = Future<U, Value.Error>()
        
        self.onComplete(context, callback: { (result: Value) in
            result.result.analysis(ifSuccess: { res.success(f($0)) }, ifFailure: { res.failure($0) })
        })
        
        return res
    }
    
    public func recover(context c: @escaping ExecutionContext = DefaultThreadingModel(), task: @escaping (Value.Error) -> Value.Value) -> Future<Value.Value, NoError> {
        return self.recoverWith(context: c) { error -> Future<Value.Value, NoError> in
            return Future<Value.Value, NoError>(value: task(error))
        }
    }
    
    public func recoverWith<E1>(context c: @escaping ExecutionContext = DefaultThreadingModel(), task: @escaping (Value.Error) -> Future<Value.Value, E1>) -> Future<Value.Value, E1> {
        let res = Future<Value.Value, E1>()
        
        self.onComplete(c) { result in
            result.result.analysis(ifSuccess: { res.success($0) }, ifFailure: { res.completeWith(task($0)) })
        }
        
        return res
    }
    
    public func mapError<E1>(_ f: @escaping (Value.Error) -> E1) -> Future<Value.Value, E1> {
        return mapError(DefaultThreadingModel(), f: f)
    }
    
    public func mapError<E1>(_ context: @escaping ExecutionContext, f: @escaping (Value.Error) -> E1) -> Future<Value.Value, E1> {
        let res = Future<Value.Value, E1>()
        
        self.onComplete(context) { result in
            result.result.analysis(ifSuccess: { res.success($0) }, ifFailure: { res.failure(f($0)) })
        }
        
        return res
    }
    
    public func zip<U>(_ that: Future<U, Value.Error>) -> Future<(Value.Value,U), Value.Error> {
        return flatMap(ImmediateExecutionContext) { thisVal -> Future<(Value.Value,U), Value.Error> in
            return that.map(ImmediateExecutionContext) { thatVal in
                return (thisVal, thatVal)
            }
        }
    }
    
    public func filter(_ p: @escaping (Value.Value) -> Bool) -> Future<Value.Value, BrightFuturesError<Value.Error>> {
        return self.mapError(ImmediateExecutionContext) { error in
            return BrightFuturesError(external: error)
            }.flatMap(ImmediateExecutionContext) { value -> Result<Value.Value, BrightFuturesError<Value.Error>> in
                if p(value) {
                    return Result(value: value)
                } else {
                    return Result(error: .noSuchElement)
                }
        }
    }
    
    public func forceType<U, E1>() -> Future<U, E1> {
        return self.map(ImmediateExecutionContext) {
            $0 as! U
            }.mapError(ImmediateExecutionContext) {
                $0 as! E1
        }
    }
    
    public func asVoid() -> Future<Void, Value.Error> {
        return self.map(ImmediateExecutionContext) { _ in return () }
    }
}

public extension AsyncType where Value: ResultProtocol, Value.Value: AsyncType, Value.Value.Value: ResultProtocol, Value.Error == Value.Value.Value.Error {
    public func flatten() -> Future<Value.Value.Value.Value, Value.Error> {
        let f = Future<Value.Value.Value.Value, Value.Error>()
        
        onComplete(ImmediateExecutionContext) { (res) in
            
            res.result.analysis(ifSuccess: { (innerFuture) -> () in
                innerFuture.onComplete(ImmediateExecutionContext, callback: { (resultProtocol) in
                    resultProtocol.result.analysis(ifSuccess: { f.success($0) }, ifFailure: { err in f.failure(err) })
                })
            }, ifFailure: {_ in})
        }

        
        return f
    }
    
}

public extension AsyncType where Value: ResultProtocol, Value.Error == NoError {
    public func promoteError<E>() -> Future<Value.Value, E> {
        return mapError(ImmediateExecutionContext) { $0 as! E } // future will never fail, so this map block will never get called
    }
}

public extension AsyncType where Value: ResultProtocol, Value.Error == BrightFuturesError<NoError> {
    public func promoteError<E>() -> Future<Value.Value, BrightFuturesError<E>> {
        return mapError(ImmediateExecutionContext) { err in
            switch err {
            case .noSuchElement:
                return BrightFuturesError<E>.noSuchElement
            case .invalidationTokenInvalidated:
                return BrightFuturesError<E>.invalidationTokenInvalidated
            case .illegalState:
                return BrightFuturesError<E>.illegalState
            case .external(_):
                fatalError("Encountered BrightFuturesError.External with NoError, which should be impossible")
            }
        }
    }
}

public extension AsyncType where Value: ResultProtocol, Value.Value == NoValue {
    public func promoteValue<T>() -> Future<T, Value.Error> {
        return map(ImmediateExecutionContext) { $0 as! T } // future will never succeed, so this map block will never get called
    }
}
