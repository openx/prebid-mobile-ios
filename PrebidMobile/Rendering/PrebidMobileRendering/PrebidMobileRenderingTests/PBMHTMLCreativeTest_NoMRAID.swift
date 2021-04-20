//
//  PBMHTMLCreativeNoMRAID.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import PrebidMobileRendering

class PBMHTMLCreativeTest_NoMRAID : PBMHTMLCreativeTest_Base {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testNoMRAID() {
        logToFile = .init()
        
        let sdkConfiguration = PBMSDKConfiguration()
        
        
        let serverConnection = PBMServerConnection(userAgentService: MockUserAgentService())
        serverConnection.protocolClasses.add(MockServerURLProtocol.self)

        let mockWebView = MockPBMWebView()
        let oxmHTMLCreative = PBMHTMLCreative(
            creativeModel: MockPBMCreativeModel(),
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: mockWebView,
               sdkConfiguration:sdkConfiguration
        )
        let mockMRAIDController = PBMMRAIDController(creative:oxmHTMLCreative,
                                                     viewControllerForPresenting:UIViewController(),
                                                     webView:mockWebView,
                                                     creativeViewDelegate:self,
                                                     downloadBlock:createLoader(connection: serverConnection),
                                                     deviceAccessManagerClass: MockPBMDeviceAccessManager.self,
                                                        sdkConfiguration: sdkConfiguration)
        oxmHTMLCreative.mraidController = mockMRAIDController
        oxmHTMLCreative.view = mockWebView
        
        //non-mraid command
        oxmHTMLCreative.webView(mockWebView, receivedMRAIDLink:URL(string: "mraid:non_cmd")!)
        let log = PBMLog.singleton.getLogFileAsString()
        XCTAssert(log.contains("Unrecognized MRAID command non_cmd"))
    }
}
