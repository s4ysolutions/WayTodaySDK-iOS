//
//  WayTodaySDKTests.swift
//  WayTodaySDKTests
//
//  Created by  Sergey Dolin on 07.06.2020.
//  Copyright © 2020 S4Y Solutions. All rights reserved.
//

import XCTest
@testable import WayTodaySDK

class WayTodaySDKTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWSSEDigest() throws {
        let digest = WSSE.digest(appname: "app", secret: "secret")
        let r = digest.range(of: "Username=\"app\",PasswordDigest=\"")
        XCTAssert(r != nil)
        XCTAssert(!r!.isEmpty)
        let d = digest.distance(from: digest.startIndex, to: r!.lowerBound)
        XCTAssert(d == 0)
        print(digest)
    }

    func testWSSEDigestPerformance() throws {
        self.measure {
            
        }
    }

}
