//
//  PBMDFPInterstitialTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileGAMEventHandlers

class PBMDFPInterstitialTest: XCTestCase {
    
    private class DummyDelegate: NSObject, GADFullScreenContentDelegate {
    }
    
    private class DummyEventDelegate: NSObject, GADAppEventDelegate {
    }
    
    func testProperties() {
        XCTAssertTrue(GAMInterstitialAdWrapper.classesFound)
        
        let propTests: [BasePropTest<GAMInterstitialAdWrapper>] = [
            RefProxyPropTest(keyPath: \.fullScreenContentDelegate, value: DummyDelegate()),
            RefProxyPropTest(keyPath: \.appEventDelegate, value: DummyEventDelegate()),
        ]
        
        let interstitial = GAMInterstitialAdWrapper(adUnitID: "/21808260008/prebid_oxb_html_interstitial")
                
        for nextTest in propTests {
            nextTest.run(object: interstitial)
        }
    }
}
