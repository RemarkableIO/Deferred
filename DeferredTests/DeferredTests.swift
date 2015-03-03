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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPromiseResolve() {

        let deferred = Deferred<String>()
        var val: String!

        deferred.then({ str in
            val = str
            }, { error in
                println(error)
        })

        deferred.resolve("String")

        XCTAssert(val == "String", "Resolve Failed")

    }

    func testPromiseReject() {
        let errorDomain = "SomeDomain"
        let errorCode = 0

        let deferred = Deferred<String>()
        var err: NSError!

        deferred.then({ str -> () in

            }, { error in
                err = error
        })

        deferred.reject(NSError(domain: errorDomain, code: errorCode, userInfo: nil))
        let testAgainst = NSError(domain: errorDomain, code: errorCode, userInfo: nil)
        
        XCTAssert(err == testAgainst, "Reject Failed")
    }
    
}
