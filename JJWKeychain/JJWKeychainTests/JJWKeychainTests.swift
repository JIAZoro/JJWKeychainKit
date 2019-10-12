//
//  JJWKeychainTests.swift
//  JJWKeychainTests
//
//  Created by mrjia on 2019/10/11.
//  Copyright © 2019 norchant. All rights reserved.
//

import XCTest
@testable import JJWKeychain

class JJWKeychainTests: XCTestCase {
    let stringValue = "test Value"
    let stringKey = "tesKkey"
    let inValue = 18
    let intKey = 19
    let decimalValue = 3.14
    let decimaKey = "test.keychain.io"
    let arrayValue = [1,2,3,4]
    let arrayKey = "testArray.keychain.io"
    var kcWrapper: JJWKeychainKit!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        let appIdentifier = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as! String
        kcWrapper = JJWKeychainKit(serviceName: "test.jjw.keychain", accessGroup: "\(appIdentifier)com.jiajingwei.JJWKeychainDemo")
//        kcWrapper = JJWKeychainKit(serviceName: "jia")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        kcWrapper.removeAllKeys()
        super.tearDown()
    }

    func testExample() {
        guard kcWrapper.set(stringValue, forKey: stringKey) else {
            XCTFail("set value of \(stringValue) for key \(stringKey) failed;")
            return
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
