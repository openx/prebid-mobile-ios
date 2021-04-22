//
//  PBMVastLoaderFacadeMultiWrapper.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import PrebidMobileRendering

class PBMVastLoaderMultiWrapperTest: XCTestCase {
    
    var vastRequestFailureExpectation:XCTestExpectation!
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    override func setUp() {
        self.continueAfterFailure = true
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
    }
    
    func testVastTooManyWrappers () {
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()

        MockServer.singleton().resetRules([
            MockServerRule(urlNeedle: "http://foo.com/", mimeType:  MockServerMimeType.XML.rawValue, connectionID: conn.internalID, fileName: "document_with_one_wrapper_ad.xml")
            ])
        
        self.vastRequestFailureExpectation = self.expectation(description: "Expected VAST Load to be failure")

        conn.protocolClasses.add(MockServerURLProtocol.self)
        
        //Make an PBMAdConfiguration
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.adFormat = .videoInternal
        
        let adLoadManager = MockPBMAdLoadManagerVAST(connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            XCTFail("Request must be failure")
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTAssertTrue(error.localizedDescription.contains("Wrapper limit reached"))
            self.vastRequestFailureExpectation.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml") {
            requester.buildAdsArray(data)
        }
                
        self.waitForExpectations(timeout: 1, handler: nil)
    }
}
