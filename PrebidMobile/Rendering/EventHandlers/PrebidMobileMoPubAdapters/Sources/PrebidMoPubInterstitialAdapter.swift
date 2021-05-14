//
//  PrebidMoPubInterstitialAdapter.swift
//  PrebidMobileMoPubAdapters
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

import MoPubSDK

import PrebidMobileRendering

@objc(PrebidMoPubInterstitialAdapter)
public class PrebidMoPubInterstitialAdapter :
    MPFullscreenAdAdapter,
    PBMInterstitialControllerLoadingDelegate,
    PBMInterstitialControllerInteractionDelegate {
    
    // MARK: - Private Properties
    
    var interstitialController: PBMInterstitialController?
    weak var rootViewController: UIViewController?
    var configID: String?
    var adAvailable = false
    
    // MARK: - MPFullscreenAdAdapter
    
    override public var hasAdAvailable: Bool {
        get { adAvailable }
        set { adAvailable = newValue }
    }
    
    public override func requestAd(withAdapterInfo info: [AnyHashable : Any], adMarkup: String?) {
        guard !localExtras.isEmpty else {
            let error = MoPubAdaptersError.emptyLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        guard let bid = localExtras[PBMMoPubAdUnitBidKey] as? PBMBid else {
            let error = MoPubAdaptersError.noBidInLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        guard let configID = localExtras[PBMMoPubConfigIdKey] as? String else {
            let error = MoPubAdaptersError.noConfigIDInLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        interstitialController = PBMInterstitialController(bid: bid, configId: configID)
        interstitialController?.loadingDelegate = self
        interstitialController?.interactionDelegate = self
        
        interstitialController?.loadAd()
        
        MPLogging.logEvent(MPLogEvent.adLoadAttempt(forAdapter: Self.className(), dspCreativeId: nil, dspName: nil), source: adUnitId, from: nil)
    }
    
    public override func presentAd(from viewController: UIViewController) {
        MPLogging.logEvent(MPLogEvent.adShowAttempt(forAdapter: Self.className()), source: adUnitId, from: nil)

        if hasAdAvailable {
            rootViewController = viewController
            interstitialController?.show()
        } else {
            let error = MoPubAdaptersError.noAd
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
        }
    }
        
    // MARK: - PBMInterstitialControllerLoadingDelegate
    
    public func interstitialControllerDidLoadAd(_ interstitialController: PBMInterstitialController) {
        adAvailable = true
        
        MPLogging.logEvent(MPLogEvent.adLoadSuccess(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.fullscreenAdAdapterDidLoadAd(self)
    }
    
    public func interstitialController(_ interstitialController: PBMInterstitialController, didFailWithError error: Error) {
        adAvailable = false
        
        MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
        delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
    }
    
    // MARK: - PBMInterstitialControllerInteractionDelegate
    
    public func trackImpression(for interstitialController: PBMInterstitialController) {
        //Impressions will be tracked automatically
        //unless enableAutomaticImpressionAndClickTracking = NO
        //In this case you have to override the didDisplayAd method
        //and manually call inlineAdAdapterDidTrackImpression
        //in this method to ensure correct metrics
    }
    
    public func interstitialControllerDidClickAd(_ interstitialController: PBMInterstitialController) {
        MPLogging.logEvent(MPLogEvent.adTapped(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.fullscreenAdAdapterDidReceiveTap(self)
    }
    
    public func interstitialControllerDidCloseAd(_ interstitialController: PBMInterstitialController) {
        adAvailable = false
        
        MPLogging.logEvent(MPLogEvent.adWillDisappear(forAdapter: Self.className()), source: adUnitId, from: nil)
        MPLogging.logEvent(MPLogEvent.adDidDisappear(forAdapter: Self.className()), source: adUnitId, from: nil)

        delegate?.fullscreenAdAdapterAdWillDisappear(self)
        delegate?.fullscreenAdAdapterAdDidDisappear(self)
    }
    
    public func interstitialControllerDidLeaveApp(_ interstitialController: PBMInterstitialController) {
        MPLogging.logEvent(MPLogEvent.adWillLeaveApplication(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.fullscreenAdAdapterWillLeaveApplication(self)
    }
    
    public func viewControllerForModalPresentation(from interstitialController: PBMInterstitialController) -> UIViewController? {
        rootViewController
    }
    
    public func interstitialControllerDidDisplay(_ interstitialController: PBMInterstitialController) {
        let className = Self.className()
        
        MPLogging.logEvent(MPLogEvent.adWillAppear(forAdapter: className), source: adUnitId, from: nil)
        MPLogging.logEvent(MPLogEvent.adDidAppear(forAdapter: className), source: adUnitId, from: nil)
        MPLogging.logEvent(MPLogEvent.adShowSuccess(forAdapter: className), source: adUnitId, from: nil)

        delegate?.fullscreenAdAdapterAdWillAppear(self)
        delegate?.fullscreenAdAdapterAdDidAppear(self)
    }
}