//
//  PrebidMRAIDFullScreenUITest.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

//Make String implement Error so we can throw Strings
extension String: Error{}

class PrebidMRAIDFullScreenUITest: RepeatedUITestCase {

    private let waitingTimeout = 8.0
    private let title = "MRAID 2.0: Fullscreen (PPM)"
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testMRAIDFullScreen() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample(title)
            
            waitAd()
            
            //Wait a short time
            Thread.sleep(forTimeInterval:8)

            do {
                let (onScreen, offScreen) = try getTimerValues(app:app)
                print ("OnScreen: \(onScreen), OffScreen: \(offScreen)")
            } catch {
                XCTFail("error: \(error)")
            }
        }
    }
    
    private func waitAd() {
        let adReceivedButton = app.buttons["adViewDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFailToLoadAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
    
    private func getTimerValues(app: XCUIApplication) throws -> (String, String) {
        let testWebView = app.webViews["PBMInternalWebViewAccessibilityIdentifier"]
        let allStaticTexts = testWebView.staticTexts.allElementsBoundByIndex
        
        var offScreenTimerFrame: CGRect?
        var onScreenTimerFrame: CGRect?
        
        for staticText in allStaticTexts {
            if staticText.label.range(of: "Off screen timer:") != nil {
                offScreenTimerFrame = staticText.frame
            }
            
            if staticText.label.range(of: "On screen timer:") != nil {
                onScreenTimerFrame = staticText.frame
            }
        }
        
        //Validate that both frames were found
        guard let unwrappedOffScreenTimerFrame = offScreenTimerFrame, let unwrappedOnScreenTimerFrame = onScreenTimerFrame else {
            throw "Could not find the frames of both timers' labels"
        }
        
        //Now that we have the frames of the labels, walk the list again to find the values
        var offScreenTimerVal: String?
        var onScreenTimerVal: String?
        
        for staticText in allStaticTexts {
            if staticText.label.range(of: "00:") != nil {
                if staticText.frame.origin.y == unwrappedOnScreenTimerFrame.origin.y {
                    onScreenTimerVal = staticText.label
                }
                
                if staticText.frame.origin.y == unwrappedOffScreenTimerFrame.origin.y {
                    offScreenTimerVal = staticText.label
                }
            }
        }
        
        //Validate
        guard let unwrappedOffScreenTimerVal = offScreenTimerVal, let unwrappedOnScreenTimerVal = onScreenTimerVal else {
            throw "Could not find both timers' values!"
        }
        
        return (unwrappedOnScreenTimerVal, unwrappedOffScreenTimerVal)
    }

}
