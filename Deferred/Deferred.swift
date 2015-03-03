//
//  Deferred.swift
//  Deferred
//
//  Created by Giles Van Gruisen on 3/2/15.
//  Copyright (c) 2015 Remarkable.io. All rights reserved.
//

import Foundation

internal struct Then<T> {
    let onFulfilled: T -> ()
    let onRejected: NSError -> ()
}

public final class Deferred<T> {

    typealias ThenBlock = Then<T>

    private typealias WrappedFulfilledBlock = T -> ()
    public typealias RejectedBlock = NSError -> ()

    var value: T?
    var error: NSError?
    var pending: [ThenBlock] = [ThenBlock]()

    public required init() { } // Shouldn't be necessary?

    public func then<U>(onFulfilled: (T -> U), _ onRejected: RejectedBlock = { error in }) -> Deferred<U> {

        let deferred = Deferred<U>()

        let _onFulfilled = wrapFulfilledBlock(deferred, onFulfilled: onFulfilled)
        let _onRejected = wrapRejectedBlock(deferred, onRejected: onRejected)

        if let value = value {
            _onFulfilled(value)
        } else if let error = error {
            onRejected(error)
        } else {
            pending.append(ThenBlock(onFulfilled: _onFulfilled, onRejected: _onRejected))
        }

        return deferred
    }

    public func resolve(value: T) {
        self.value = value

        for thenBlock in pending {
            thenBlock.onFulfilled(value)
        }

        self.pending = [ThenBlock]()
    }

    public func reject(error: NSError) {
        for thenBlock in pending {
            thenBlock.onRejected(error)
        }

        self.pending = [ThenBlock]()
    }

    public func wrapFulfilledBlock<U>(deferred: Deferred<U>, onFulfilled: T -> U) -> WrappedFulfilledBlock {
        return { val in
            deferred.resolve(onFulfilled(val))
        }
    }

    public func wrapRejectedBlock<U>(deferred: Deferred<U>, onRejected: NSError -> ()) -> RejectedBlock {
        return { err in
            onRejected(err)
            deferred.reject(err)
        }
    }
}