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

class DeferredTests: XCTestCase {

    func testPromiseResolve() {
        let deferred = Deferred<String>()
        var val = "Wrong String"

        deferred.then({ str in
            val = str
            }, { error in
                println(error)
        })

        deferred.resolve("Right String")
        XCTAssert(val == "Right String", "Resolve Failed")
    }

    func testPromiseReject() {
        let deferred = Deferred<String>()
        var error: NSError = NSError()

        deferred.then({ str -> () in }, { err in
            error = err
        })

        deferred.reject(exampleError())
        XCTAssert(error == exampleError(), "Reject Failed")
    }

    func testImmediateResolve() {
        var val = "Wrong String"

        Deferred<String>(value: "Right String").then { str in
            val = str
        }

        XCTAssert(val == "Right String", "Immediate Resolved Failed")
    }

    func testImmediateReject() {
        var error: NSError = NSError()
        let deferred = Deferred<String>(error: exampleError())

        deferred.then({ str -> () in }, { err in
            error = err
        })

        XCTAssert(error == exampleError(), "Immediate Reject Failed")
    }

    func exampleError() -> NSError {
        return NSError(domain: "Some Domain", code: 0, userInfo: nil)
    }
}
