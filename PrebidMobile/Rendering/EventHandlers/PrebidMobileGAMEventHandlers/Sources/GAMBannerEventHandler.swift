//
//  GAMBannerEventHandler.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileRendering


fileprivate let appEvent = "PrebidAppEvent"
fileprivate let appEventTimeout = 0.6;

class GAMBannerEventHandler :
    NSObject,
    PBMBannerEventHandler,
    GADBannerViewDelegate,
    GADAppEventDelegate,
    GADAdSizeDelegate
{
    var requestBanner: PBMGAMBanner?
    var oxbProxyBanner: PBMGAMBanner?
    var embeddedBanner: PBMGAMBanner?
    
    var validAdSizes: [NSValue]
    
    var isExpectingAppEvent = false;
    var appEventTimer: Timer?
    
    var lastGADSize: CGSize?
    
    let adUnitID: String
    
    init(adUnitID: String, adSizes: [NSValue]) {
        self.adUnitID = adUnitID
        self.adSizes = GAMBannerEventHandler.convertGADSizes(adSizes)
        
        validAdSizes = adSizes
    }
    
    // MARK: PBMBannerEventHandler
    
    var loadingDelegate: PBMBannerEventLoadingDelegate?
    
    var interactionDelegate: PBMBannerEventInteractionDelegate?
    
    var adSizes: [NSValue]
    
    var isCreativeRequiredForNativeAds: Bool {
        false
    }
    
    func requestAd(with bidResponse: PBMBidResponse?) {
        if !(PBMGAMBanner.classesFound && PBMGAMRequest.classesFound) {
            let error = PBMGAMError.gamClassesNotFound
            PBMGAMError.logError(error)
            loadingDelegate?.failedWithError(error)
            return
        }
        
        if let _ = requestBanner {
            // request to primaryAdServer in progress
            return;
        }
        
        requestBanner = PBMGAMBanner()
        requestBanner?.adUnitID = adUnitID
        requestBanner?.validAdSizes = validAdSizes
        requestBanner?.rootViewController = interactionDelegate?.viewControllerForPresentingModal
        
        let request = PBMGAMRequest()
        if let bidResponse = bidResponse {
            isExpectingAppEvent = bidResponse.winningBid != nil
            
            var targeting = [AnyHashable : Any]()
              
            if let requestTargeting = request.customTargeting {
                targeting.merge(requestTargeting) { $1 }
            }
            
            if let responseTargeting = bidResponse.targetingInfo {
                targeting.merge(responseTargeting) { $1 }
            }
            
            if !targeting.isEmpty {
                request.customTargeting = targeting
            }
        }
        
        requestBanner?.delegate = self
        requestBanner?.appEventDelegate = self
        requestBanner?.adSizeDelegate = self
        requestBanner?.enableManualImpressions = true
        
        lastGADSize = nil;
        
        requestBanner?.load(request)
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if requestBanner?.view == bannerView {
            primaryAdReceived()
        }
    }
    
    func bannerView(_ bannerView: GADBannerView,
                    didFailToReceiveAdWithError error: Error) {
        if requestBanner?.view == bannerView {
            requestBanner = nil
            recycleCurrentBanner()
            loadingDelegate?.failedWithError(error)
        }
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        // TODO
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        interactionDelegate?.willPresentModal()
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        // TODO
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        interactionDelegate?.didDismissModal()
    }
    
    // MARK: - GADAppEventDelegate
    
    func adView(_ banner: GADBannerView,
                didReceiveAppEvent name: String, withInfo info: String?) {
        if requestBanner?.view == banner && name == appEvent {
            appEventDeected()
        }
    }
    
    func interstitialAd(_ interstitialAd: GADInterstitialAd,
                        didReceiveAppEvent name: String, withInfo info: String?) {
        // TODO
    }
    
    // MARK: - GADAdSizeDelegate
    
    func adView(_ bannerView: GADBannerView,
                willChangeAdSizeTo size: GADAdSize) {
        lastGADSize = size.size
    }
    
    // MARK: - Private Helpers
    
    var dfpAdSize: CGSize? {
        if let lastSize = lastGADSize {
            return lastSize
        } else if let banner = requestBanner {
            return banner.adSize.size
        }
        
        return nil
    }

    func primaryAdReceived() {
        if isExpectingAppEvent {
            if let _ = appEventTimer {
                return
            }
            
            appEventTimer = Timer.scheduledTimer(timeInterval: appEventTimeout,
                                                 target: self,
                                                 selector: #selector(appEventTimedOut),
                                                 userInfo: nil,
                                                 repeats: false)
        } else {
            let banner = requestBanner
            requestBanner = nil
            
            recycleCurrentBanner()
            embeddedBanner = banner
            
            if  let banner = banner,
                let adSize = dfpAdSize {
                loadingDelegate?.adServerDidWin(banner.view, adSize: adSize)
            }
        }
    }
    
    func appEventDeected() {
        let banner = requestBanner
        requestBanner = nil
        if isExpectingAppEvent {
            if let _ = appEventTimer {
                appEventTimer?.invalidate()
                appEventTimer = nil
            }
            
            isExpectingAppEvent = false
            recycleCurrentBanner()
            
            oxbProxyBanner = banner
            
            loadingDelegate?.prebidDidWin()
        }
    }
    
    @objc func appEventTimedOut() {
        let banner = requestBanner
        requestBanner = nil
        
        recycleCurrentBanner()
        
        embeddedBanner = banner
        
        isExpectingAppEvent = false
        appEventTimer = nil
        
        if  let banner = banner,
            let adSize = dfpAdSize {
            loadingDelegate?.adServerDidWin(banner.view, adSize: adSize)
        }
    }
    
    func recycleCurrentBanner() {
        embeddedBanner = nil
        oxbProxyBanner = nil
    }
    
    class func convertGADSizes(_ inSizes: [NSValue]) -> [NSValue] {
        inSizes.map {
            CGSizeFromGADAdSize(GADAdSizeFromNSValue( $0 )) as NSValue
        }
    }
    
}


