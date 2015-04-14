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
    internal var pending: [ThenBlock] = [ThenBlock]()

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

    /** Returns a collective promise that resolves with a collection of T when all resolve */
    public class func combine(promises: [Deferred<T>]) -> Deferred<[T]> {
        let combined = Deferred<[T]>()

        var collection = [T]()

        for deferred in promises {
            deferred.then({ value -> Void in
                collection += [value]

                if collection.count == promises.count {
                    combined.resolve(collection)
                }
            })
        }

        return combined
    }

    /** Appends to `pending` a `Then<T>` object containing the given `onFulfilled` and (optional) `onRejected` blocks, or calls onFulfilled/onRejected if the promise is already fulfilled or rejected, respectively. */
    public func then<U>(onFulfilled: (T) -> U, _ onRejected: RejectedBlock = { error in }) -> Deferred<U> {

        // Chained promise to be returned
        let deferred = Deferred<U>()

        // Curry onFulfilled and onRejected before appending ThenBlock to `pending`
        let _onFulfilled = wrapFulfilledBlock(deferred, onFulfilled: onFulfilled)
        let _onRejected = wrapRejectedBlock(deferred, onRejected: onRejected)

        // Check promise status
        if let value = value {

            // Fulfilled, call onFulfilled immediately
            _onFulfilled(value)

        } else if let error = error {

            // Rejected, call onRejected immediately
            _onRejected(error)

        } else {

            // Pending, add ThenBlock
            pending.append(ThenBlock(onFulfilled: _onFulfilled, onRejected: _onRejected))

        }

        return deferred
    }

    public func then<U>(onFulfilled: (T) -> Deferred<U>, _ onRejected: RejectedBlock = { error in }) -> Deferred<U> {

        let temp = Deferred<U>()

        let _onFulfilled: T -> () = { value in
            let next = onFulfilled(value)
            if let nextValue = next.value {
                temp.resolve(nextValue)
            } else if let nextError = next.error {
                temp.reject(nextError)
            } else {
                temp.pending += next.pending
            }
        }

        let _onRejected: NSError -> () = { error in
            temp.reject(error)
        }

        if let value = value {
            _onFulfilled(value)
        } else if let error = error {
            _onRejected(error)
        } else {
            pending += [ThenBlock(onFulfilled: _onFulfilled, onRejected: _onRejected)]
        }

        return temp
    }

    /** Resolve the promise, clearing `pending` after calling each `onFulfilled` block with the given `value`. */
    public func resolve(value: T) {
        // Promise fulfilled, set value
        self.value = value

        // Loop through ThenBlocks, calling each onFulfilled with value
        for thenBlock in pending {
            thenBlock.onFulfilled(value)
        }

        // Clear pending now that promise has been fulfilled
        self.pending = [ThenBlock]()
    }

    /** Rejects the promise, clearing `pending` after calling each `onRejected` block with the given `error`. */
    public func reject(error: NSError) {
        // Promise rejected, set error
        self.error = error

        // Loop through ThenBlocks, calling each onRejected with error
        for thenBlock in pending {
            thenBlock.onRejected(error)
        }

        // Clear pending now that promise has been rejected
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
