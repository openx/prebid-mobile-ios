//
//  PBMDFPRequestTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileGAMEventHandlers

class GAMRequestWrapperTest: XCTestCase {
    func testProperties() {
        XCTAssertTrue(GAMBannerViewWrapper.classesFound)
        
        let propTests: [BasePropTest<GAMRequestWrapper>] = [
            DicPropTest(keyPath: \.customTargeting, value: ["key": "unknown"]),
        ]
        
        let request = GAMRequestWrapper()
        
        for nextTest in propTests {
            nextTest.run(object: request)
        }
    }
}
