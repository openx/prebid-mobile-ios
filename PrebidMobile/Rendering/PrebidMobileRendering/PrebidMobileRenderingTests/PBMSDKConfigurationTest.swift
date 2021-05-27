//
//  PBMSDKConfigurationTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMSDKConfigurationTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        
        PBMSDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    func testInitialValues() {
        let sdkConfiguration = PrebidRenderingConfig.shared
        
        // PBMSDKConfiguration
        
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeout, 6.0)
        XCTAssertEqual(sdkConfiguration.creativeFactoryTimeoutPreRenderContent, 30.0)

        XCTAssertFalse(sdkConfiguration.useExternalClickthroughBrowser)
        
        // Prebid-specific
        
        XCTAssertEqual(sdkConfiguration.accountID, "")
        XCTAssertEqual(sdkConfiguration.prebidServerHost, .custom)
    }
    
    func testInitializeSDK() {
        logToFile = .init()
        
        PBMSDKConfiguration.initializeSDK()
        
        let log = PBMLog.singleton.getLogFileAsString()
        
        XCTAssert(log.contains("prebid-mobile-sdk-rendering \(PBMFunctions.sdkVersion()) Initialized"))
    }
    
    func testLogLevel() {
        // FIXME: fix the type mismatch after PBMLog will be ported
        
        let sdkConfiguration = PrebidRenderingConfig.shared

        XCTAssertEqual(sdkConfiguration.logLevel, PBMLog.singleton.logLevel)
        
        sdkConfiguration.logLevel = PBMLogLevel.none
        XCTAssertEqual(PBMLog.singleton.logLevel, PBMLogLevel.none)
        
        PBMLog.singleton.logLevel = PBMLogLevel.info
        XCTAssertEqual(sdkConfiguration.logLevel, PBMLogLevel.info)
    }
    
    func testDebugLogFileEnabled() {
        
        let sdkConfiguration = PrebidRenderingConfig.shared
        let initialValue = sdkConfiguration.debugLogFileEnabled
        
        XCTAssertEqual(initialValue, PBMLog.singleton.logToFile)
        
        sdkConfiguration.debugLogFileEnabled = !initialValue
        XCTAssertEqual(PBMLog.singleton.logToFile, !initialValue)

        PBMLog.singleton.logToFile = initialValue
        XCTAssertEqual(sdkConfiguration.debugLogFileEnabled, initialValue)
    }
    
    func testLocationValues() {
        let sdkConfiguration = PrebidRenderingConfig.shared
        XCTAssertTrue(sdkConfiguration.locationUpdatesEnabled)
        sdkConfiguration.locationUpdatesEnabled = false
        XCTAssertFalse(sdkConfiguration.locationUpdatesEnabled)
    }
    
    func testSingleton() {
        let firstConfig = PrebidRenderingConfig.shared
        let newConfig = PrebidRenderingConfig.shared
        XCTAssertEqual(firstConfig, newConfig)
    }
    
    func testResetSingleton() {
        let firstConfig = PrebidRenderingConfig.shared
        PBMSDKConfiguration.resetSingleton()
        let newConfig = PrebidRenderingConfig.shared
        XCTAssertNotEqual(firstConfig, newConfig)
    }
    
    func testPrebidHost() {
        let sdkConfig = PrebidRenderingConfig.shared
        XCTAssertEqual(sdkConfig.prebidServerHost, .custom)
        
        sdkConfig.prebidServerHost = .appnexus
        XCTAssertEqual(try! PBMHost.shared.getHostURL(host:sdkConfig.prebidServerHost), "https://prebid.adnxs.com/pbs/v1/openrtb2/auction")
        
        let _ = try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://10.0.2.2:8000/openrtb2/auction")
        XCTAssertEqual(sdkConfig.prebidServerHost, .custom)
        
    }
    
    func testServerHostCustomInvalid() throws {
        XCTAssertThrowsError(try PrebidRenderingConfig.shared.setCustomPrebidServer(url: "wrong url"))
    }
}
