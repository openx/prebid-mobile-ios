//
//  RewardedAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import UIKit


public class RewardedAdUnit: PBMBaseInterstitialAdUnit,
                         PBMRewardedEventInteractionDelegate {
   
    @objc public private(set) var reward: NSObject?
    
    // MARK: - Lifecycle
    
    @objc public override init(configId: String, eventHandler: Any) {
        super.init(configId: configId, eventHandler: eventHandler)
            
        adUnitConfig.isOptIn = true
        adFormat = .video
    }

    @objc public override convenience init(configId: String) {
        self.init(configId: configId, eventHandler: PBMRewardedEventHandlerStandalone())
    }
    
    override init(configId:String, minSizePerc: NSValue?, eventHandler:Any?) {
        super.init(configId: configId, minSizePerc:minSizePerc, eventHandler:eventHandler)
        
    }
    
    // MARK: - PBMRewardedEventDelegate
    @objc public func userDidEarnReward(_ reward: NSObject?) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.reward = reward
            self?.callDelegate_rewardedAdUserDidEarnReward()
        })
        
    }
    
    // MARK: - PBMBaseInterstitialAdUnitProtocol protocol
    
    @objc public override func interstitialControllerDidCloseAd(_ interstitialController: PBMInterstitialController) {
        callDelegate_rewardedAdUserDidEarnReward()
        super.interstitialControllerDidCloseAd(interstitialController)
    }

    // MARK: - Protected overrides
    
    @objc public override func callDelegate_didReceiveAd() {
        let delegate = self.delegate as? PBMRewardedAdUnitDelegate
        delegate?.rewardedAdDidReceiveAd?(self)
    }

    @objc public override func callDelegate_didFailToReceiveAdWithError(_ error: Error?) {
        let delegate = self.delegate as? PBMRewardedAdUnitDelegate
        delegate?.rewardedAd?(self, didFailToReceiveAdWithError: error)
    }
    
    @objc public override func callDelegate_willPresentAd() {
        let delegate = self.delegate as? PBMRewardedAdUnitDelegate
        delegate?.rewardedAdWillPresentAd?(self)
    }

    @objc public override func callDelegate_didDismissAd() {
        let delegate = self.delegate as? PBMRewardedAdUnitDelegate
        delegate?.rewardedAdDidDismissAd?(self)
    }

    @objc public override func callDelegate_willLeaveApplication() {
        let delegate = self.delegate as? PBMRewardedAdUnitDelegate
        delegate?.rewardedAdWillLeaveApplication?(self)
    }

    @objc public override func callDelegate_didClickAd() {
        let delegate = self.delegate as? PBMRewardedAdUnitDelegate
        delegate?.rewardedAdDidClickAd?(self)
    }
    
    @objc public override func callEventHandler_isReady() -> Bool {
        let eventHandler = self.eventHandler as? PBMRewardedEventHandler
        return eventHandler?.isReady ?? false
    }

    @objc public override func callEventHandler_setLoadingDelegate(_ loadingDelegate: PBMRewardedEventLoadingDelegate) {
        let eventHandler = self.eventHandler as? PBMRewardedEventHandler
        eventHandler?.loadingDelegate = loadingDelegate
    }

    @objc public override func callEventHandler_setInteractionDelegate() {
        let eventHandler = self.eventHandler as? PBMRewardedEventHandler
        eventHandler?.interactionDelegate = self
    }

    @objc public override func callEventHandler_requestAd(with bidResponse: PBMBidResponse?) {
        let eventHandler = self.eventHandler as? PBMRewardedEventHandler
        eventHandler?.requestAd(with: bidResponse)
    }

    @objc public override func callEventHandler_show(from controller: UIViewController?) {
        let eventHandler = self.eventHandler as? PBMRewardedEventHandler
        eventHandler?.show(from: controller)
    }

    @objc public override func callEventHandler_trackImpression() {
        let eventHandler = self.eventHandler as? PBMRewardedEventHandler
        eventHandler?.trackImpression?()
    }
    
    // MARK: - Private helpers
    
    func callDelegate_rewardedAdUserDidEarnReward() {
        let delegate = self.delegate as? PBMRewardedAdUnitDelegate
        delegate?.rewardedAdUserDidEarnReward?(self)
    }
}
