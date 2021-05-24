//
//  PBMBaseInterstitialAdUnit_DelegationTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

@testable import PrebidMobileRendering

class PBMBaseInterstitialAdUnit_DelegationTest: XCTestCase {
    override func tearDown() {
        PBMSDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    private let configId = "someConfigId"
    
    func testInterstitialDelegateCalls_noOptionalMethods() {
        let adUnit = InterstitialAdUnit(configId: configId)
        let delegate = DummyInterstitialDelegate()
        adUnit.delegate = delegate
        callInterstitialDelegateMethods(adUnit: adUnit)
    }
    
    func testInterstitialDelegateCalls_receiveAllMethods() {
        let adUnit = InterstitialAdUnit(configId: configId)
        let delegate = InterstitialProxyDelegate()
        adUnit.delegate = delegate
        callInterstitialDelegateMethods(adUnit: adUnit, proxyDelegate: delegate)
    }
    
    func testRewardedAdDelegateCalls_noOptionalMethods() {
        let adUnit = RewardedAdUnit(configId: configId)
        let delegate = DummyRewardedAdDelegate()
        adUnit.delegate = delegate
        callRewardedAdDelegateMethods(adUnit: adUnit)
    }
    
    func testRewardedAdDelegateCalls_receiveAllMethods() {
        let adUnit = RewardedAdUnit(configId: configId)
        let delegate = RewardedAdProxyDelegate()
        adUnit.delegate = delegate
        callRewardedAdDelegateMethods(adUnit: adUnit, proxyDelegate: delegate)
    }
    
    func testAccountErrorPropagationByInterstitial() {
        let testID = "auid"
        
        PBMSDKConfiguration.singleton.accountID = ""
        
        let interstitial = InterstitialAdUnit(configId: testID)
        let exp = expectation(description: "loading callback called")
        let delegate = InterstitialProxyDelegate()
        interstitial.delegate = delegate
        delegate.onCall = { selector, args in
            XCTAssertEqual(selector, "interstitial:didFailToReceiveAdWithError:")
            XCTAssertEqual(args.count, 2)
            XCTAssertEqual(args[0] as? InterstitialAdUnit, interstitial)
            XCTAssertEqual(args[1] as? NSError, PBMError.invalidAccountId as NSError?)
            exp.fulfill()
        }
        
        interstitial.loadAd()
        
        waitForExpectations(timeout: 3)
    }
    
    func testAccountErrorPropagationByRewardedAd() {
        let testID = "auid"
        
        PBMSDKConfiguration.singleton.accountID = ""
        
        let rewarded = RewardedAdUnit(configId: testID)
        let exp = expectation(description: "loading callback called")
        let delegate = RewardedAdProxyDelegate()
        rewarded.delegate = delegate
        delegate.onCall = { selector, args in
            XCTAssertEqual(selector, "rewardedAd:didFailToReceiveAdWithError:")
            XCTAssertEqual(args.count, 2)
            XCTAssertEqual(args[0] as? RewardedAdUnit, rewarded)
            XCTAssertEqual(args[1] as? NSError, PBMError.invalidAccountId as NSError?)
            exp.fulfill()
        }
        
        rewarded.loadAd()
        
        waitForExpectations(timeout: 3)
    }
    
    // MARK: - Helper classes
    
    private class DummyInterstitialDelegate: NSObject, PBMInterstitialAdUnitDelegate {}
    private class DummyRewardedAdDelegate: NSObject, PBMRewardedAdUnitDelegate {}
    
    private class BaseProxyDelegate: NSObject {
        let file: StaticString
        let line: UInt
        
        var onCall: ((String, [Any]) -> ())?
        
        init(file: StaticString = #file, line: UInt = #line) {
            self.file = file
            self.line = line
        }
        
        func report(selectorName: String, args: [Any]) {
            if let reportBlock = onCall {
                reportBlock(selectorName, args)
            } else {
                XCTFail("onCall not assigned", file: file, line: line)
            }
        }
    }
    
    private class InterstitialProxyDelegate: BaseProxyDelegate, PBMInterstitialAdUnitDelegate {
        func interstitialDidReceiveAd(_ interstitial: InterstitialAdUnit) {
            report(selectorName: "interstitialDidReceiveAd:", args: [interstitial])
        }
        func interstitial(_ interstitial: InterstitialAdUnit, didFailToReceiveAdWithError error: Error?) {
            report(selectorName: "interstitial:didFailToReceiveAdWithError:", args: [interstitial, error as Any])
        }
        func interstitialWillPresentAd(_ interstitial: InterstitialAdUnit) {
            report(selectorName: "interstitialWillPresentAd:", args: [interstitial])
        }
        func interstitialDidDismissAd(_ interstitial: InterstitialAdUnit) {
            report(selectorName: "interstitialDidDismissAd:", args: [interstitial])
        }
        func interstitialWillLeaveApplication(_ interstitial: InterstitialAdUnit) {
            report(selectorName: "interstitialWillLeaveApplication:", args: [interstitial])
        }
        func interstitialDidClickAd(_ interstitial: InterstitialAdUnit) {
            report(selectorName: "interstitialDidClickAd:", args: [interstitial])
        }
    }
    
    private class RewardedAdProxyDelegate: BaseProxyDelegate, PBMRewardedAdUnitDelegate {
        func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdDidReceiveAd:", args: [rewardedAd])
        }
        func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
            report(selectorName: "rewardedAd:didFailToReceiveAdWithError:", args: [rewardedAd, error as Any])
        }
        func rewardedAdWillPresentAd(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdWillPresentAd:", args: [rewardedAd])
        }
        func rewardedAdDidDismissAd(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdDidDismissAd:", args: [rewardedAd])
        }
        func rewardedAdWillLeaveApplication(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdWillLeaveApplication:", args: [rewardedAd])
        }
        func rewardedAdDidClickAd(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdDidClickAd:", args: [rewardedAd])
        }
        func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdUserDidEarnReward:", args: [rewardedAd])
        }
    }
    
    // MARK: - Helper Methods (Static)

    private static func buildFailOnCall(expectedSelector: String?, file: StaticString = #file, line: UInt = #line) -> (String, [Any]) -> () {
        let expectationText: String
        if let expectedSelector = expectedSelector {
            expectationText = " while expecting [\(expectedSelector)]"
        } else {
            expectationText = ""
        }
        return { calledSelector, passedArgs in
            XCTFail("Unexpected call to '\(calledSelector)' with args: \(passedArgs)" + expectationText,
                    file: file, line: line)
        }
    }
    
    private static func callDelegateMethod(proxyDelegate: BaseProxyDelegate?,
                                           expectedSelector: String, expectedArgs: [Any],
                                           file: StaticString = #file, line: UInt = #line,
                                           block: () throws -> ())
    {
        var called = false
        proxyDelegate?.onCall = { calledSelector, passedArgs in
            guard calledSelector == expectedSelector else {
                buildFailOnCall(expectedSelector: expectedSelector, file: file, line: line)(calledSelector, passedArgs)
                return
            }
            guard !called else {
                XCTFail("Multiple calls to [\(expectedSelector)]", file: file, line: line)
                return
            }
            XCTAssertFalse(called, file: file, line: line)
            called = true
            XCTAssertEqual(calledSelector, expectedSelector)
            XCTAssertEqual(passedArgs.count, expectedArgs.count)
            for i in 0..<expectedArgs.count {
                let passed = passedArgs[i] as AnyObject as? NSObject
                let expected = expectedArgs[i] as AnyObject as? NSObject
                XCTAssertEqual(passed, expected, file: file, line: line)
            }
        }
        XCTAssertNoThrow(try block(), file: file, line: line)
        proxyDelegate?.onCall = buildFailOnCall(expectedSelector: nil)
        XCTAssertEqual(called, proxyDelegate != nil, "delegate method [\(expectedSelector)] not called", file: file, line: line)
    }
    
    private func callProtectedSelectors(baseAdUnit: PBMBaseInterstitialAdUnitProtocol,
                                        proxyDelegate: BaseProxyDelegate?,
                                        selectorPrefix: String?,
                                        file: StaticString = #file, line: UInt = #line)
    {
        enum FakeError: Error {
            case someFakeError
        }
        
        let prefix = selectorPrefix ?? ""
        
        func testCall(_ expectedSelector: String, args expectedArgs: [Any], block: () throws -> ()) {
            PBMBaseInterstitialAdUnit_DelegationTest.callDelegateMethod(proxyDelegate: proxyDelegate,
                                                                        expectedSelector: expectedSelector,
                                                                        expectedArgs: expectedArgs,
                                                                        file: file, line: line,
                                                                        block: block)
        }
        
        testCall("\(prefix)DidReceiveAd:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_didReceiveAd()
        }
        testCall("\(prefix):didFailToReceiveAdWithError:", args: [baseAdUnit, FakeError.someFakeError]) {
            baseAdUnit.callDelegate_didFailToReceiveAdWithError(FakeError.someFakeError)
        }
        testCall("\(prefix)WillPresentAd:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_willPresentAd()
        }
        testCall("\(prefix)DidDismissAd:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_didDismissAd()
        }
        testCall("\(prefix)WillLeaveApplication:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_willLeaveApplication()
        }
        testCall("\(prefix)DidClickAd:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_didClickAd()
        }
    }
    
    private func callInterstitialDelegateMethods(adUnit: InterstitialAdUnit,
                                                 proxyDelegate: InterstitialProxyDelegate? = nil,
                                                 file: StaticString = #file, line: UInt = #line)
    {
        callProtectedSelectors(baseAdUnit: adUnit,
                               proxyDelegate: proxyDelegate,
                               selectorPrefix: "interstitial",
                               file: file, line: line)
    }
    
    private func callRewardedAdDelegateMethods(adUnit: RewardedAdUnit,
                                               proxyDelegate: RewardedAdProxyDelegate? = nil,
                                               file: StaticString = #file, line: UInt = #line)
    {
        func testCall(_ expectedSelector: String, args expectedArgs: [Any], block: () throws -> ()) {
            PBMBaseInterstitialAdUnit_DelegationTest.callDelegateMethod(proxyDelegate: proxyDelegate,
                                                                        expectedSelector: expectedSelector,
                                                                        expectedArgs: expectedArgs,
                                                                        file: file, line: line,
                                                                        block: block)
        }
        
        callProtectedSelectors(baseAdUnit: adUnit,
                               proxyDelegate: proxyDelegate,
                               selectorPrefix: "rewardedAd",
                               file: file, line: line)
        
        testCall("rewardedAdUserDidEarnReward:", args: [adUnit]) {
            adUnit.callDelegate_rewardedAdUserDidEarnReward()
        }
    }
    
}
