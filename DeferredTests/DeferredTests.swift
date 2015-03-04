//
//  DeferredTests.swift
//  DeferredTests
//
//  Created by Giles Van Gruisen on 3/2/15.
//  Copyright (c) 2015 Remarkable.io. All rights reserved.
//

import UIKit
import XCTest
import Deferred

public extension XCTestCase {
    public func expectPromise<T>(deferred: Deferred<T>, onFulfilled: T -> () = { t in }, onRejected: NSError -> () = { e in }) {
        let expectation = expectationWithDescription("Promise should resolve or reject")

        let _onFulfilled: T -> () = { (value: T) in
            onFulfilled(value)
            expectation.fulfill()
        }

        let _onRejected: NSError -> () = { (error: NSError) in
            onRejected(error)
            expectation.fulfill()
        }

        deferred.then(_onFulfilled, _onRejected)
    }
}

class DeferredTests: XCTestCase {

    func testPromiseResolve() {
        let deferred = Deferred<String>()

        expectPromise(deferred) { str in
            XCTAssert(str == "Right String", "Promise resolved with unexpected value")
        }

        deferred.resolve("Right String")

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPromiseReject() {
        let deferred = Deferred<String>()
        let rejectWith = NSError(domain: "Some Domain", code: 0, userInfo: nil)

        expectPromise(deferred, onRejected: { error in
            XCTAssert(error == rejectWith, "Reject failed")
        })

        deferred.reject(rejectWith)

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testImmediateResolve() {
        let resolveWith = "Some String"

        expectPromise(Deferred<String>(value: resolveWith)) { str in
            XCTAssert(str == resolveWith, "Immediate Resolved Failed")
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testImmediateReject() {
        let rejectWith = NSError(domain: "Some Domain", code: 0, userInfo: nil)

        expectPromise(Deferred<String>(error: rejectWith), onRejected: { error in
            XCTAssert(error == rejectWith, "Immediate Reject Failed")
        })

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
