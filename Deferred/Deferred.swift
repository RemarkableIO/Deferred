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

    /** If `value` is filled then the promise was resolved. */
    private var value: T?

    /** If `error` is filled then the promise was rejected. */
    private var error: NSError?

    /** `ThenBlock` objects whose onFulfilled or onRejected will be called upon `resolve(value: T)` or `reject(error: NSError)`, respectively. */
    private var pending: [ThenBlock] = [ThenBlock]()

    /** Returns an empty (unresolved, unrejected) promise. */
    public required init() { } // Shouldn't be necessary?

    /** Returns a promise resolved with the given `value`. */
    public convenience init(value: T) {
        self.init()
        self.resolve(value)
    }

    /** Returns a promise rejected with the given `error`. */
    public convenience init(error: NSError) {
        self.init()
        self.reject(error)
    }

    /** Appends to `pending` a `Then<T, U>` object containing the given `onFulfilled` and (optional) `onRejected` blocks. */
    public func then<U>(onFulfilled: (T -> U), _ onRejected: RejectedBlock = { error in }) -> Deferred<U> {

        let deferred = Deferred<U>()

        let _onFulfilled = wrapFulfilledBlock(deferred, onFulfilled: onFulfilled)
        let _onRejected = wrapRejectedBlock(deferred, onRejected: onRejected)

        if let value = value {
            _onFulfilled(value)
        } else if let error = error {
            _onRejected(error)
        } else {
            pending.append(ThenBlock(onFulfilled: _onFulfilled, onRejected: _onRejected))
        }

        return deferred
    }

    /** Resolve the promise, clearing `pending` after calling each `onFulfilled` block with the given `value`. */
    public func resolve(value: T) {
        self.value = value

        for thenBlock in pending {
            thenBlock.onFulfilled(value)
        }

        self.pending = [ThenBlock]()
    }

    /** Rejects the promise, clearing `pending` after calling each `onRejected` block with the given `error`. */
    public func reject(error: NSError) {
        self.error = error

        for thenBlock in pending {
            thenBlock.onRejected(error)
        }

        self.pending = [ThenBlock]()
    }

    private func wrapFulfilledBlock<U>(deferred: Deferred<U>, onFulfilled: T -> U) -> WrappedFulfilledBlock {
        return { val in
            deferred.resolve(onFulfilled(val))
        }
    }

    private func wrapRejectedBlock<U>(deferred: Deferred<U>, onRejected: NSError -> ()) -> RejectedBlock {
        return { err in
            onRejected(err)
            deferred.reject(err)
        }
    }
}