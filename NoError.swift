//
//  NoError.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

public enum NoError: Swift.Error, Equatable {
    public static func ==(lhs: NoError, rhs: NoError) -> Bool {
        return true
    }
}
