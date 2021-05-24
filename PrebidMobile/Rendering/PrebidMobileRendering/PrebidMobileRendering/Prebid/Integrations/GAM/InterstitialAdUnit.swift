//
//  InterstitialAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import UIKit

public class InterstitialAdUnit: PBMBaseInterstitialAdUnit {

    @objc public override init(configId: String) {
        super.init(configId: configId, eventHandler: PBMInterstitialEventHandlerStandalone())
    }

    @objc public override init(configId: String, minSizePercentage: CGSize) {
        super.init(
            configId: configId,
            minSizePercentage: minSizePercentage,
            eventHandler: PBMInterstitialEventHandlerStandalone())
    }

    @objc public override init(configId: String, minSizePercentage:CGSize, eventHandler: Any) {
        super.init(configId: configId, minSizePercentage: minSizePercentage, eventHandler: eventHandler)
    }
    
    override init(configId:String, minSizePerc: NSValue?, eventHandler:Any?) {
        super.init(configId: configId, minSizePerc:minSizePerc, eventHandler:eventHandler)
    }
    
    
    // MARK: - Protected overrides

    @objc public override func callDelegate_didReceiveAd() {
        let delegate = self.delegate as? PBMInterstitialAdUnitDelegate
        delegate?.interstitialDidReceiveAd?(self)
    }
    
    @objc public override func callDelegate_didFailToReceiveAdWithError(_ error: Error?) {
        let delegate = self.delegate as? PBMInterstitialAdUnitDelegate
        delegate?.interstitial?(self, didFailToReceiveAdWithError: error)
    }

    @objc public override func callDelegate_willPresentAd() {
        let delegate = self.delegate as? PBMInterstitialAdUnitDelegate
        delegate?.interstitialWillPresentAd?(self)
    }

    @objc public override func callDelegate_didDismissAd() {
        let delegate = self.delegate as? PBMInterstitialAdUnitDelegate
        delegate?.interstitialDidDismissAd?(self)
    }

    @objc public override func callDelegate_willLeaveApplication() {
        let delegate = self.delegate as? PBMInterstitialAdUnitDelegate
        delegate?.interstitialWillLeaveApplication?(self)
    }

    @objc public override func callDelegate_didClickAd() {
        let delegate = self.delegate as? PBMInterstitialAdUnitDelegate
        delegate?.interstitialDidClickAd?(self)
    }
    
    
    
    @objc public override func callEventHandler_isReady() -> Bool {
        let eventHandler = self.eventHandler as? PBMInterstitialEventHandler
        return eventHandler?.isReady ?? false
    }

    @objc public override func callEventHandler_setLoadingDelegate(_ loadingDelegate: PBMRewardedEventLoadingDelegate?) {
        let eventHandler = self.eventHandler as? PBMInterstitialEventHandler
        eventHandler?.loadingDelegate = loadingDelegate
    }

    @objc public override func callEventHandler_setInteractionDelegate() {
        let eventHandler = self.eventHandler as? PBMInterstitialEventHandler
        eventHandler?.interactionDelegate = self
    }

    @objc public override func callEventHandler_requestAd(with bidResponse: PBMBidResponse?) {
        let eventHandler = self.eventHandler as? PBMInterstitialEventHandler
        eventHandler?.requestAd(with: bidResponse)
    }

    @objc public override func callEventHandler_show(from controller: UIViewController?) {
        let eventHandler = self.eventHandler as? PBMInterstitialEventHandler
        eventHandler?.show(from: controller)
    }

    @objc public override func callEventHandler_trackImpression() {
        let eventHandler = self.eventHandler as? PBMInterstitialEventHandler
        eventHandler?.trackImpression?()
    }
}
