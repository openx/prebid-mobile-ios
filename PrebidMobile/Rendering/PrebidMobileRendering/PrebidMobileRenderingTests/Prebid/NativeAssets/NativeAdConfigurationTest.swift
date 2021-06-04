//
//  NativeAdConfigurationTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class NativeAdConfigurationTest: XCTestCase {

    func testSetupConfig() {
        let desc = NativeAssetData(dataType: .desc)
        let nativeAdConfig = NativeAdConfiguration.init(assets:[desc])
        
        nativeAdConfig.context = .socialCentric
        nativeAdConfig.contextsubtype = .applicationStore
        nativeAdConfig.plcmttype = .feedGridListing
        nativeAdConfig.seq = 1
        
        let nativeMarkupObject = nativeAdConfig.markupRequestObject
        
        XCTAssertEqual(nativeMarkupObject.context, PBMNativeContextType.socialCentric)
        XCTAssertEqual(nativeMarkupObject.contextsubtype, PBMNativeContextSubtype.applicationStore)
        XCTAssertEqual(nativeMarkupObject.plcmttype, PBMNativePlacementType.feedGridListing)
        XCTAssertEqual(nativeMarkupObject.seq, 1)
        
        nativeAdConfig.context = .undefined
        nativeAdConfig.contextsubtype = .undefined
        nativeAdConfig.plcmttype = .undefined
        nativeAdConfig.seq = -1
        
        XCTAssertNil(nativeMarkupObject.context)
        XCTAssertNil(nativeMarkupObject.contextsubtype)
        XCTAssertNil(nativeMarkupObject.plcmttype)
        XCTAssertNil(nativeMarkupObject.seq)
    }
}
