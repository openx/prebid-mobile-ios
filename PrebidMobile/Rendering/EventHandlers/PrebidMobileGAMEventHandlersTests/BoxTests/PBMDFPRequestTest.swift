//
//  PBMDFPRequestTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileGAMEventHandlers

class PBMDFPRequestTest: XCTestCase {
    func testProperties() {
        XCTAssertTrue(PBMGAMBanner.classesFound)
        
        let propTests: [BasePropTest<PBMGAMRequest>] = [
            DicPropTest(keyPath: \.customTargeting, value: ["key": "unknown"]),
        ]
        
        let request = PBMGAMRequest()
        
        for nextTest in propTests {
            nextTest.run(object: request)
        }
    }
}
