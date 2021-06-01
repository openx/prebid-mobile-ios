//
//  InterstitialAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import UIKit

public class InterstitialAdUnit: PBMBaseInterstitialAdUnit {

    @objc public override init(configId: String) {
        super.init(configId: configId, eventHandler: InterstitialEventHandlerStandalone())
    }

    @objc public override init(configId: String, minSizePercentage: CGSize) {
        super.init(
            configId: configId,
            minSizePercentage: minSizePercentage,
            eventHandler: InterstitialEventHandlerStandalone())
    }

    @objc public override init(configId: String, minSizePercentage:CGSize, eventHandler: Any) {
        super.init(
            configId: configId,
            minSizePercentage: minSizePercentage,
            eventHandler: eventHandler)
    }
    
    override init(configId:String, minSizePerc: NSValue?, eventHandler:Any?) {
        super.init(
            configId: configId,
            minSizePerc:minSizePerc,
            eventHandler:eventHandler)
    }
    
    
    // MARK: - Protected overrides

    @objc public override func callDelegate_didReceiveAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidReceiveAd?(self)
        }
    }
    
    @objc public override func callDelegate_didFailToReceiveAdWithError(_ error: Error?) {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitial?(self, didFailToReceiveAdWithError: error)
        }
    }

    @objc public override func callDelegate_willPresentAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialWillPresentAd?(self)
        }
    }

    @objc public override func callDelegate_didDismissAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidDismissAd?(self)
        }
    }

    @objc public override func callDelegate_willLeaveApplication() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialWillLeaveApplication?(self)
        }
    }

    @objc public override func callDelegate_didClickAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidClickAd?(self)
        }
    }
    
    
    
    @objc public override func callEventHandler_isReady() -> Bool {
        if let eventHandler = self.eventHandler as? InterstitialEventHandlerProtocol {
            return eventHandler.isReady
        } else {
            return false
        }
    }

    @objc public override func callEventHandler_setLoadingDelegate(_ loadingDelegate: RewardedEventLoadingDelegate?) {
        if let eventHandler = self.eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.loadingDelegate = loadingDelegate
        }
    }

    @objc public override func callEventHandler_setInteractionDelegate() {
        if let eventHandler = self.eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.interactionDelegate = self
        }
    }

    @objc public override func callEventHandler_requestAd(with bidResponse: BidResponse?) {
        if let eventHandler = self.eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.requestAd(with: bidResponse)
        }
    }

    @objc public override func callEventHandler_show(from controller: UIViewController?) {
        if let eventHandler = self.eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.show(from: controller)
        }
    }

    @objc public override func callEventHandler_trackImpression() {
        if let eventHandler = self.eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.trackImpression?()
        }
    }
}
