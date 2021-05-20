//
//  MoPubBannerAdUnitTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMMoPubBannerAdUnitTest: XCTestCase {
    let testID = "auid"
    let primarySize = CGSize(width: 320, height: 50)
    
    private let sdkConfiguration: PBMSDKConfiguration = {
        let config = PBMSDKConfiguration()
//        config.serverURL = PBMSDKConfiguration.devintServerURL
        try! config.setCustomPrebidServer(url: PBMSDKConfiguration.devintServerURL)
        config.accountID = PBMSDKConfiguration.devintAccountID
        return config
    }()
    private let targeting = PBMTargeting.withDisabledLock
    
    func testConfigSetup() {
        let bannerAdUnit = MoPubBannerAdUnit(configID: testID, size: primarySize)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        XCTAssertEqual(adUnitConfig.configId, testID)
        XCTAssertEqual(adUnitConfig.adSize?.cgSizeValue, primarySize)
        
        let moreSizes = [
            CGSize(width: 300, height: 250),
            CGSize(width: 728, height: 90),
        ]
        
        bannerAdUnit.additionalSizes = moreSizes.map(NSValue.init(cgSize:))
        
        XCTAssertEqual(adUnitConfig.additionalSizes?.count, moreSizes.count)
        for i in 0..<moreSizes.count {
            XCTAssertEqual(adUnitConfig.additionalSizes?[i].cgSizeValue, moreSizes[i])
        }
        
        let refreshInterval: TimeInterval = 40;
        
        bannerAdUnit.refreshInterval = refreshInterval
        XCTAssertEqual(adUnitConfig.refreshInterval, refreshInterval)
    }
    
    func testWrongAdObject() {
        let adUnit = MoPubBannerAdUnit(configID: testID, size: primarySize)
        let asyncExpectation = expectation(description: "fetchDemand executed")
        adUnit.fetchDemand(with: NSString()) { result in
            XCTAssertEqual(result, .wrongArguments)
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
    func testAdObjectSetUpCleanUp() {
        @objc class MoPubAdObject: NSObject {
            var keywords: String?
            var localExtras: [AnyHashable : Any]?
        }
        
        //a good response with a bid
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.someValidResponse)
            }])
        let initialKeywords = "key1,key2"
        
        let adObject = MoPubAdObject()
        adObject.keywords = initialKeywords
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnit = MoPubBannerAdUnit(configID: configId, size: primarySize)
        
        let asyncExpectation = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(with: adObject,
                           connection: connection,
                           sdkConfiguration: sdkConfiguration,
                           targeting: targeting)
        { result in
            XCTAssertEqual(result, .ok)
            
            let resultKeywords = adObject.keywords!
            XCTAssertTrue(resultKeywords.contains("hb_pb:0.10"))
            
            let resultExtras: [AnyHashable : Any] = adObject.localExtras!
            XCTAssertEqual(resultExtras.count, 2)
            XCTAssertEqual(resultExtras[PBMMoPubConfigIdKey] as? String, configId)
            let bid = resultExtras[PBMMoPubAdUnitBidKey] as! NSObject
            XCTAssertTrue(bid.isKind(of: PBMBid.self))
            
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        
        //a bad response with the same ad object without bids
        
        let noBidConnection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.serverErrorResponse)
            }])
        
        let asyncExpectation2 = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(with: adObject,
                           connection: noBidConnection,
                           sdkConfiguration: sdkConfiguration,
                           targeting: targeting)
        { result in
            XCTAssertEqual(result, .serverError)
            
            let resultKeywords = adObject.keywords!
            XCTAssertEqual(resultKeywords, initialKeywords)
            let resultExtras: [AnyHashable : Any] = adObject.localExtras!
            XCTAssertEqual(resultExtras.count, 0)
            
            asyncExpectation2.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
}
