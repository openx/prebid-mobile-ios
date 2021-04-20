import XCTest

@testable import PrebidMobileRendering

class PBMVastLoaderTestWrapperPlusInline: XCTestCase {

    var didFetchInline:XCTestExpectation!
    var vastRequestSuccessfulExpectation:XCTestExpectation!
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    
    override func setUp() {
        self.continueAfterFailure = true
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
        self.didFetchInline = nil
        self.vastRequestSuccessfulExpectation = nil
    }
    
    func testRequest() {
        
        self.didFetchInline = self.expectation(description: "Expected PBMServerConnection to hit foo.com/inline")
        self.vastRequestSuccessfulExpectation = self.expectation(description: "vastRequestSuccessfulExpectation #1")
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        ////////////////////////////
        //Mock a server at "foo.com"
        ////////////////////////////
        MockServer.singleton().reset()
        let ruleInline =  MockServerRule(urlNeedle: "foo.com/inline/vast", mimeType:  MockServerMimeType.XML.rawValue, connectionID: conn.internalID, fileName: "document_with_one_inline_ad.xml")
        ruleInline.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            PBMLog.info("didFetchInline.fulfill()")
            self.didFetchInline.fulfill()
        }
        
        MockServer.singleton().resetRules([ruleInline])
        
        //Handle 404's
        MockServer.singleton().notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTFail("Unexpected request for \(urlRequest)")
        }
        
        //////////////////////////////////////////////////////////////////////////////////
        //Make an PBMServerConnection and redirect its network requests to the Mock Server
        //////////////////////////////////////////////////////////////////////////////////
        

        let adConfiguration = PBMAdConfiguration()
        
        let adLoadManager = MockPBMAdLoadManagerVAST(connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.vastRequestSuccessfulExpectation.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail(error.localizedDescription)
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml") {
            requester.buildAdsArray(data)
        }
                
        self.waitForExpectations(timeout: 2)
        
        guard let response = self.vastServerResponse else {
            XCTFail()
            return
        }
        
        check(response)
        
        let inlineVastRequestSuccessfulExpectation = self.expectation(description: "Expected Inline VAST Load to be successful")

        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        
        modelMaker.makeModels(response,
                              successCallback: { models in
                                let createModelCount = 2  // For video interstitials with End Card, count is 2. Includes all companions.
                                XCTAssertEqual(models.count, createModelCount)
                                inlineVastRequestSuccessfulExpectation.fulfill()
        },
                              failureCallback: { error in
                                inlineVastRequestSuccessfulExpectation.fulfill()
                                XCTFail(error.localizedDescription)
        })

        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    // MARK: - Check result
    
    func check(_ response: NSObject) {
        guard let vastResponse = response as? PBMAdRequestResponseVAST else {
            XCTFail()
            return
        }
        
        guard let ads = vastResponse.ads else {
            XCTFail()
            return
        }
        
        //There should be 1 ad.
        //An Ad can be either inline or wrapper; this should be inline.
        if (ads.count != 1) {
            XCTFail("Expected 1 ad, got \(ads.count)")
            return
        }
        
        let ad = ads.first!
        
        PBMAssertEq(ad.adSystem, "Inline AdSystem")
        PBMAssertEq(ad.adSystemVersion, "1.0")
        PBMAssertEq(ad.errorURIs, ["http://myErrorURL/AdError"])
        PBMAssertEq(ad.impressionURIs, ["http://myTrackingURL/inline/impression", "http://myTrackingURL/inline/anotherImpression", "http://myTrackingURL/wrapper/impression", "http://myTrackingURL/wrapper/anotherImpression"])
        
        //There should be 3 creatives:
        //a Linear Creative
        //a Companion ad Creative composed of two companions (an image and an iframe)
        //And a NonlinearAds Creative composed of two Nonlinear ads (an image and an iframe)
        PBMAssertEq(ad.creatives.count, 3)
        
        //Creative 1  - Linear
        let oxmVastCreativeLinear = ad.creatives[0] as! PBMVastCreativeLinear
        PBMAssertEq(oxmVastCreativeLinear.AdId, "601364")
        PBMAssertEq(oxmVastCreativeLinear.id, "6012")
        PBMAssertEq(oxmVastCreativeLinear.sequence, 1)
        PBMAssertEq(oxmVastCreativeLinear.duration, 6)
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["creativeView"], ["http://myTrackingURL/inline/creativeView", "http://myTrackingURL/wrapper/creativeView"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["start"], ["http://myTrackingURL/inline/start1", "http://myTrackingURL/inline/start2", "http://myTrackingURL/wrapper/start1", "http://myTrackingURL/wrapper/start2"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["midpoint"], ["http://myTrackingURL/inline/midpoint", "http://myTrackingURL/wrapper/midpoint"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["firstQuartile"], ["http://myTrackingURL/inline/firstQuartile", "http://myTrackingURL/wrapper/firstQuartile"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["thirdQuartile"], ["http://myTrackingURL/inline/thirdQuartile", "http://myTrackingURL/wrapper/thirdQuartile"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["complete"], ["http://myTrackingURL/inline/complete", "http://myTrackingURL/wrapper/complete"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["mute"], ["http://myTrackingURL/inline/mute", "http://myTrackingURL/wrapper/mute"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["unmute"], ["http://myTrackingURL/inline/unmute", "http://myTrackingURL/wrapper/unmute"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["pause"], ["http://myTrackingURL/inline/pause", "http://myTrackingURL/wrapper/pause"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["rewind"], ["http://myTrackingURL/inline/rewind", "http://myTrackingURL/wrapper/rewind"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["resume"], ["http://myTrackingURL/inline/resume", "http://myTrackingURL/wrapper/resume"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["fullscreen"], ["http://myTrackingURL/inline/fullscreen", "http://myTrackingURL/wrapper/fullscreen"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["expand"], ["http://myTrackingURL/inline/expand", "http://myTrackingURL/wrapper/expand"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["collapse"], ["http://myTrackingURL/inline/collapse", "http://myTrackingURL/wrapper/collapse"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["acceptInvitation"], ["http://myTrackingURL/inline/acceptInvitation", "http://myTrackingURL/wrapper/acceptInvitation"])
        PBMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["close"], ["http://myTrackingURL/inline/close", "http://myTrackingURL/wrapper/close"])
        
        PBMAssertEq(oxmVastCreativeLinear.adParameters, "params=for&request=gohere")
        PBMAssertEq(oxmVastCreativeLinear.clickThroughURI, "http://www.openx.com")
        PBMAssertEq(oxmVastCreativeLinear.clickTrackingURIs, ["http://myTrackingURL/inline/click1", "http://myTrackingURL/inline/click2", "http://myTrackingURL/inline/custom1", "http://myTrackingURL/inline/custom2", "http://myTrackingURL/wrapper/click1", "http://myTrackingURL/wrapper/click2", "http://myTrackingURL/wrapper/custom1", "http://myTrackingURL/wrapper/custom2"])
        
        PBMAssertEq(oxmVastCreativeLinear.mediaFiles.count, 1)
        
        let mediaFile = oxmVastCreativeLinear.mediaFiles.firstObject as! PBMVastMediaFile
        PBMAssertEq(mediaFile.id, "firstFile")
        PBMAssertEq(mediaFile.streamingDeliver, false)
        PBMAssertEq(mediaFile.type, "video/mp4")
        PBMAssertEq(mediaFile.bitrate, 500)
        PBMAssertEq(mediaFile.width, 400)
        PBMAssertEq(mediaFile.height, 300)
        PBMAssertEq(mediaFile.scalable, true)
        PBMAssertEq(mediaFile.maintainAspectRatio, true)
        PBMAssertEq(mediaFile.apiFramework, "VPAID")
        PBMAssertEq(mediaFile.mediaURI, "http://get_video_file")
        
        
        //Creative 2 - CompanionAds
        let oxmVastCreativeCompanionAds = ad.creatives[1] as! PBMVastCreativeCompanionAds
        PBMAssertEq(oxmVastCreativeCompanionAds.companions.count, 2)
        
        //First Companion
        let oxmVastCreativeCompanionAdsCompanion = oxmVastCreativeCompanionAds.companions[0] as! PBMVastCreativeCompanionAdsCompanion
        PBMAssertEq(oxmVastCreativeCompanionAdsCompanion.companionIdentifier, "big_box")
        PBMAssertEq(oxmVastCreativeCompanionAdsCompanion.width, 300)
        PBMAssertEq(oxmVastCreativeCompanionAdsCompanion.height, 250)
        //Should we support expandedWidth="600" expandedHeight="500" apiFramework="VPAID" ??
        PBMAssertEq(oxmVastCreativeCompanionAdsCompanion.resource, "http://demo.tremormedia.com/proddev/vast/Blistex1.jpg")
        
        //TODO: change from "staticResource" to "jpeg" or something?
        PBMAssertEq(oxmVastCreativeCompanionAdsCompanion.resourceType, PBMVastResourceType.staticResource)
        let trackingEvents = oxmVastCreativeCompanionAdsCompanion.trackingEvents.trackingEvents
        PBMAssertEq(trackingEvents.count, 2)
        PBMAssertEq(trackingEvents["creativeView"], ["http://myTrackingURL/inline/firstCompanionCreativeView"])
        PBMAssertEq(trackingEvents["creativeViewFromWrapper"], ["http://myTrackingURL/wrapper/firstCompanionCreativeView"])
        PBMAssertEq(oxmVastCreativeCompanionAdsCompanion.clickThroughURI, "http://www.openx.com")

    }
}
