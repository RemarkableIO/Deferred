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

        expectPromise(deferred, onFulfilled: { str in
            XCTAssert(str == "Right String", "Promise resolved with unexpected value")
        })

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

        expectPromise(Deferred<String>(value: resolveWith), onFulfilled: { str in
            XCTAssert(str == resolveWith, "Immediate Resolved Failed")
        })

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testImmediateReject() {
        let rejectWith = NSError(domain: "Some Domain", code: 0, userInfo: nil)

        expectPromise(Deferred<String>(error: rejectWith), onRejected: { error in
            XCTAssert(error == rejectWith, "Immediate Reject Failed")
        })

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testCombinedResolve() {

        let promises = [Int](0..<5).map { Int -> Deferred<String> in
            return Deferred<String>(value: "Some String")
        }

        expectPromise(Deferred.combine(promises), onFulfilled: { strings in
            XCTAssert(strings.count == 5, "Combined Resolve Failed")
        })

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testChainResolve() {

        let promiseA = Deferred<Int>()


        let chained = promiseA.then({ i -> Deferred<Int> in

            let promiseB = Deferred<Int>()

            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(200 * Double(NSEC_PER_MSEC)))
            dispatch_after(time, dispatch_get_main_queue()) {
                promiseB.resolve(i + 1)
            }

            return promiseB

        }).then({ i -> Int in
            return i + 1
        })

        promiseA.resolve(1)

        expectPromise(chained, onFulfilled: { i in
            XCTAssert(i == 3, "Chain failed")
        })

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testChainImmediateResolve() {

        let promiseA = Deferred<Int>(value: 1)

        let chained = promiseA.then({ i -> Deferred<Int> in
            return Deferred<Int>(value: i + 1)
        }).then({ i -> Int in
            return i + 1
        })

        expectPromise(chained, onFulfilled: { i in
            XCTAssert(i == 3, "Chain failed")
        })

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testChainReject() {

        let promiseA = Deferred<Int>()

        let chained = promiseA.then({ i -> Deferred<Int> in
            return Deferred<Int>(value: i + 1)
        }).then({ i -> Int in
            return i + 1
        })

        promiseA.reject(NSError(domain: "Reject", code: 0, userInfo: nil))

        expectPromise(chained, onRejected: { err in
            XCTAssert(err.domain == "Reject", "Chain failed")
        })

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testMultipleHandlers() {
        let resolveWith = "Some string"
        let resolvedPromise = Deferred<String>(value: resolveWith)

        expectPromise(resolvedPromise, onFulfilled: { str in
            XCTAssert(str == resolveWith, "")
        })
        
        expectPromise(resolvedPromise, onFulfilled: { str in
            XCTAssert(str == resolveWith, "Double handler failed")
        })
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
}
