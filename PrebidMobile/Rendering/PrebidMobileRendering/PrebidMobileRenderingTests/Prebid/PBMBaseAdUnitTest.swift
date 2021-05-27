//
//  PBMBaseAdUnitTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMBaseAdUnitTest: XCTestCase, WinningBidResponseFabricator {
    func testDesignatedInit_noBlockCalled() {
        let configID = "some-base-config-ID"
        
        let noRequesterCreated = expectation(description: "no requester created")
        noRequesterCreated.isInverted = true
        
        let adUnit = PBMBaseAdUnit(configID: configID) { adUnitConfig in
            XCTFail()
            return MockBidRequester(expectedCalls: [])
        } winNotifierBlock: { (bid, adMarkupStringHandler) in
            XCTFail()
            adMarkupStringHandler(nil)
        }
        
        XCTAssertEqual(adUnit.configId, configID)

        waitForExpectations(timeout: 1)
    }
    
    func testFetchDemand_Normal() {
        let configID = "some-base-config-ID"
        let bidPrice = 0.85
        let expectedAdMarkup = "<b>Some ad markup</b>"
        
        let bidResponse = makeWinningBidResponse(bidPrice: bidPrice)
        
        let requesterCreated = expectation(description: "requester created")
        let winNotNotified = expectation(description: "win not notified")
        winNotNotified.isInverted = true
        
        let winNotification = NSMutableArray(object: winNotNotified)
        
        let adUnit = PBMBaseAdUnit(configID: configID) { adUnitConfig in
            requesterCreated.fulfill()
            return MockBidRequester(expectedCalls: [
                { responseHandler in
                    responseHandler(bidResponse, nil)
                },
            ])
        } winNotifierBlock: { (bid, adMarkupStringHandler) in
            (winNotification[0] as! XCTestExpectation).fulfill()
            XCTAssertEqual(bid.price, Float(bidPrice))
            adMarkupStringHandler(expectedAdMarkup)
        }
        
        XCTAssertEqual(adUnit.configId, configID)
        
        let fetchDemandReturned = expectation(description: "fetch demand result returned")
        adUnit.fetchDemand { demandResponseInfo in
            fetchDemandReturned.fulfill()
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(demandResponseInfo.fetchDemandResult, .ok)
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(adUnit.lastBidResponse, bidResponse)
        XCTAssertNotNil(adUnit.lastDemandResponseInfo)
        
        let winNotified = expectation(description: "win notified")
        winNotification[0] = winNotified
        
        let markupStringReturned = expectation(description: "markup string returned")
        adUnit.lastDemandResponseInfo!.getAdMarkupString { adMarkup in
            markupStringReturned.fulfill()
            XCTAssertEqual(adMarkup, expectedAdMarkup)
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFetchDemand_DemandError() {
        let configID = "some-base-config-ID"
        
        let requesterCreated = expectation(description: "requester created")
        
        let adUnit = PBMBaseAdUnit(configID: configID) { adUnitConfig in
            requesterCreated.fulfill()
            return MockBidRequester(expectedCalls: [
                { responseHandler in
                    responseHandler(nil, PBMError.invalidAccountId)
                },
            ])
        } winNotifierBlock: { (bid, adMarkupStringHandler) in
            XCTFail()
            adMarkupStringHandler(nil)
        }
        
        XCTAssertEqual(adUnit.configId, configID)
        
        let fetchDemandReturned = expectation(description: "fetch demand result returned")
        adUnit.fetchDemand { demandResponseInfo in
            fetchDemandReturned.fulfill()
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(demandResponseInfo.fetchDemandResult, .invalidAccountId)
        }

        waitForExpectations(timeout: 1)
        XCTAssertNil(adUnit.lastBidResponse)
        XCTAssertNotNil(adUnit.lastDemandResponseInfo)
    }
    
    func testFetchDemand_NoBids() {
        let configID = "some-base-config-ID"
        
        let bidResponse = BidResponse(rawBidResponse: .init())
        
        let requesterCreated = expectation(description: "requester created")
        
        let adUnit = PBMBaseAdUnit(configID: configID) { adUnitConfig in
            requesterCreated.fulfill()
            return MockBidRequester(expectedCalls: [
                { responseHandler in
                    responseHandler(bidResponse, nil)
                },
            ])
        } winNotifierBlock: { (bid, adMarkupStringHandler) in
            XCTFail()
            adMarkupStringHandler(nil)
        }
        
        XCTAssertEqual(adUnit.configId, configID)
        
        let fetchDemandReturned = expectation(description: "fetch demand result returned")
        adUnit.fetchDemand { demandResponseInfo in
            fetchDemandReturned.fulfill()
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(demandResponseInfo.fetchDemandResult, .demandNoBids)
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(adUnit.lastBidResponse, bidResponse)
        XCTAssertNotNil(adUnit.lastDemandResponseInfo)
    }
    
    func testFetchDemand_RequestInProgress() {
        let configID = "some-base-config-ID"
        let bidPrice = 0.85
        let expectedAdMarkup = "<b>Some ad markup</b>"
        
        let bidResponse = makeWinningBidResponse(bidPrice: bidPrice)
        
        let requesterCreated = expectation(description: "requester created")
        let requestCompleted = expectation(description: "request completed")
        let winNotNotified = expectation(description: "win not notified")
        winNotNotified.isInverted = true
        
        let winNotification = NSMutableArray(object: winNotNotified)
        
        let adUnit = PBMBaseAdUnit(configID: configID) { adUnitConfig in
            requesterCreated.fulfill()
            return MockBidRequester(expectedCalls: [
                { responseHandler in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        requestCompleted.fulfill()
                        responseHandler(bidResponse, nil)
                    }
                },
            ])
        } winNotifierBlock: { (bid, adMarkupStringHandler) in
            (winNotification[0] as! XCTestExpectation).fulfill()
            XCTAssertEqual(bid.price, Float(bidPrice))
            adMarkupStringHandler(expectedAdMarkup)
        }
        
        XCTAssertEqual(adUnit.configId, configID)
        
        let fetchDemandReturned = expectation(description: "fetch demand result returned")
        adUnit.fetchDemand { demandResponseInfo in
            fetchDemandReturned.fulfill()
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(demandResponseInfo.fetchDemandResult, .ok)
        }
        
        let fetchDemandFailed = expectation(description: "fetch demand failed")
        adUnit.fetchDemand { demandResponseInfo in
            fetchDemandFailed.fulfill()
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(demandResponseInfo.fetchDemandResult, .sdkMisuse_PreviousFetchNotCompletedYet)
        }

        waitForExpectations(timeout: 2)
        XCTAssertEqual(adUnit.lastBidResponse, bidResponse)
        XCTAssertNotNil(adUnit.lastDemandResponseInfo)
        
        let winNotified = expectation(description: "win notified")
        winNotification[0] = winNotified
        
        let markupStringReturned = expectation(description: "markup string returned")
        adUnit.lastDemandResponseInfo!.getAdMarkupString { adMarkup in
            markupStringReturned.fulfill()
            XCTAssertEqual(adMarkup, expectedAdMarkup)
        }
        
        waitForExpectations(timeout: 1)
    }
}
