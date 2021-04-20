//
//  PBMOpenMeasurementEventTrackerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class PBMOpenMeasurementEventTrackerTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testEventsForWebViewSession() {
        let measurement = PBMOpenMeasurementWrapper()
        
        measurement.jsLib = "{}"
        
        let webViewSession = measurement.initializeWebViewSession(WKWebView(), contentUrl: nil)
        
        XCTAssertNotNil(webViewSession)
        XCTAssertNotNil(webViewSession?.eventTracker)
        
        let oxmTracker = webViewSession?.eventTracker as? PBMOpenMeasurementEventTracker
        XCTAssertNotNil(oxmTracker)
        XCTAssertNotNil(oxmTracker?.adEvents)
        
        XCTAssertNil(oxmTracker?.mediaEvents)
    }
    
    func testEventsForNativeVideoSession() {
        let measurement = PBMOpenMeasurementWrapper()
        
        measurement.jsLib = "{}"
        
        let verificationParams = PBMVideoVerificationParameters()
        let resource = PBMVideoVerificationResource()
        resource.url = "openx.com"
        resource.vendorKey = "OpenX"
        resource.params = "no params"
        verificationParams.verificationResources.add(resource)
        
        let nativeVideoSession = measurement.initializeNativeVideoSession(UIView(), verificationParameters:verificationParams)
        
        XCTAssertNotNil(nativeVideoSession)
        XCTAssertNotNil(nativeVideoSession?.eventTracker)
        
        let oxmTracker = nativeVideoSession?.eventTracker as? PBMOpenMeasurementEventTracker
        XCTAssertNotNil(oxmTracker)
        XCTAssertNotNil(oxmTracker?.adEvents)
        XCTAssertNotNil(oxmTracker?.mediaEvents)
    }
    
    func testInvalidSession() {
        logToFile = .init()
        
        var oxmTracker = PBMOpenMeasurementEventTracker(session: OMIDOpenxAdSession())
        XCTAssertNotNil(oxmTracker)
        XCTAssertNotNil(oxmTracker.session)
        UtilitiesForTesting.checkLogContains("Open Measurement can't create ad events with error")
        
        oxmTracker = PBMOpenMeasurementEventTracker()
        XCTAssertNotNil(oxmTracker)
        XCTAssertNil(oxmTracker.session)
        
        logToFile = nil
        logToFile = .init()
        
        oxmTracker.trackEvent(PBMTrackingEvent.request)        
        UtilitiesForTesting.checkLogContains("Measurement Session is missed")
    }
}
