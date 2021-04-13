//
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//
import XCTest

@testable import PrebidMobileRendering

class OXMAdRequestResponseVASTTests: XCTestCase {
    
    func testAds() {
        
        let response = OXMAdRequestResponseVAST()
        XCTAssertNotNil(response)
        XCTAssertNil(response.ads)
        
        response.ads = [OXMVastAbstractAd]()
        XCTAssertNotNil(response.ads)
        XCTAssertTrue(response.ads!.isEmpty)
        
        response.ads?.append(OXMVastInlineAd())
        XCTAssertFalse(response.ads!.isEmpty)
        
        XCTAssert(response.ads!.first?.superclass === OXMVastAbstractAd.self)
    }
}