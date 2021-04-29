//
//  GAMInterstitialEventHandler.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileRendering

fileprivate let appEvent = "PrebidAppEvent"
fileprivate let appEventTimeout = 0.6

public class GAMInterstitialEventHandler :
    NSObject,
    PBMInterstitialEventHandler,
    GADFullScreenContentDelegate,
    GADAppEventDelegate {
    
    var requestInterstitial:    GAMInterstitialAdWrapper?
    var proxyInterstitial:      GAMInterstitialAdWrapper?
    var embeddedInterstitial:   GAMInterstitialAdWrapper?
   
    var adSizes = [CGSize]()
    var isExpectingAppEvent = false
    
    var appEventTimer: Timer?
    
    public let adUnitID: String

    public init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    public var loadingDelegate: PBMInterstitialEventLoadingDelegate?
    
    public var interactionDelegate: PBMInterstitialEventInteractionDelegate?
    
    public var isReady: Bool {
        if let _ = requestInterstitial {
            return false
        }
        
        guard let _ = embeddedInterstitial ?? proxyInterstitial else {
            return false
        }
        
        return true
    }
        
  // MARK: PBMPrimaryAdRequesterProtocol
    
    public func show(from controller: UIViewController?) {
        if let controller = controller,
           let interstitial = embeddedInterstitial {
            interstitial.present(from: controller)
        }
    }
    
    public func requestAd(with bidResponse: PBMBidResponse?) {
        if !(GAMInterstitialAdWrapper.classesFound && PBMGAMRequest.classesFound) {
            let error = PBMGAMError.gamClassesNotFound
            PBMGAMError.logError(error)
            loadingDelegate?.failedWithError(error)
            return
        }
        
        if let _ = requestInterstitial {
            // request to primaryAdServer in progress
            return;
        }
        
        if proxyInterstitial != nil || proxyInterstitial != nil {
            // rewarded already loaded
            return;
        }

        requestInterstitial = GAMInterstitialAdWrapper(with: adUnitID)
        
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
        
        requestInterstitial?.fullScreenContentDelegate = self
        requestInterstitial?.appEventDelegate = self
        
        requestInterstitial?.load(request: request, completion:{ [weak self] ad, error in
            if let error = error {
                self?.interstitialdidReceive(didFailToReceive: ad, error: error)
                return
            }
            
            self?.interstitial(didReceive: ad)
        })
    }
    
    // MARK: GADAppEventDelegate
    
    func interstitial(didReceive ad: GAMInterstitialAdWrapper) {
        if requestInterstitial === ad {
            primaryAdReceived()
        }
    }

    func interstitialdidReceive(didFailToReceive ad:GAMInterstitialAdWrapper,
                                error: Error)
    {
        if requestInterstitial === ad {
            requestInterstitial = nil;
            forgetCurrentInterstitial()
            loadingDelegate?.failedWithError(error)
        }
    }

    
    public func interstitialAd(_ interstitialAd: GADInterstitialAd,
                               didReceiveAppEvent name: String,
                               withInfo info: String?) {
        if requestInterstitial?.interstitialAd === interstitialAd &&
            name == appEvent {
            appEventDetected()
        }
    }
    
    func appEventDetected() {
        if let interstitial = requestInterstitial, isExpectingAppEvent {
            if let _ = appEventTimer {
                appEventTimer?.invalidate()
                appEventTimer = nil
            }
            
            isExpectingAppEvent = false
            forgetCurrentInterstitial()
            
            proxyInterstitial = interstitial
            
            loadingDelegate?.prebidDidWin()
        }
        
        requestInterstitial = nil
    }
    
    func forgetCurrentInterstitial() {
        if let _ = embeddedInterstitial {
            embeddedInterstitial = nil
        }  else if let _ = proxyInterstitial {
            proxyInterstitial = nil
        }
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
            let interstitial = requestInterstitial
            requestInterstitial = nil
            
            forgetCurrentInterstitial()
            embeddedInterstitial = interstitial
            
            loadingDelegate?.adServerDidWin()
        }
    }
    
    @objc func appEventTimedOut() {
        let interstitial = requestInterstitial
        requestInterstitial = nil
        
        forgetCurrentInterstitial()
        embeddedInterstitial = interstitial
        
        isExpectingAppEvent = false
        
        appEventTimer = nil
        
        loadingDelegate?.adServerDidWin()
    }
}
