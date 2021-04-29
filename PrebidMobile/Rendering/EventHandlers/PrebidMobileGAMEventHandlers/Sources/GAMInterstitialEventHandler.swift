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
    
    var requestInterstitial: PBMDFPInterstitial?
    var oxbProxyInterstitial: PBMDFPInterstitial?
    var embeddedInterstitial: PBMDFPInterstitial?
   
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
        
        guard let loadedInterstitial = embeddedInterstitial ?? oxbProxyInterstitial else {
            return false
        }
        
        return loadedInterstitial.isReady
    }
        
  // MARK: PBMPrimaryAdRequesterProtocol
    
    public func show(from controller: UIViewController?) {
        if let controller = controller,
           let interstitial = embeddedInterstitial,
           interstitial.isReady {
            interstitial.present(fromRootViewController: controller)
        }
    }
    
    public func requestAd(with bidResponse: PBMBidResponse?) {
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
        
        requestInterstitial?.delegate = self
        requestInterstitial?.appEventDelegate = self
        
        requestInterstitial?.load(request)
    }
    
    // MARK: GADAppEventDelegate
    
    func interstitial(didReceive ad:PBMDFPInterstitial) {
        if requestInterstitial == ad {
            primaryAdReceived()
        }
    }

    func interstitialdidReceive(didFailToReceive ad:PBMDFPInterstitial,
                                error: Error)
    {
        if requestInterstitial == ad {
            requestInterstitial = nil;
            forgetCurrentInterstitial()
            loadingDelegate?.failedWithError(error)
        }
    }

    
    public func interstitialAd(_ interstitialAd: GADInterstitialAd,
                               didReceiveAppEvent name: String,
                               withInfo info: String?) {
        if requestInterstitial?.boxedInterstitial === interstitialAd &&
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
            
            oxbProxyInterstitial = interstitial
            
            loadingDelegate?.prebidDidWin()
        }
        
        requestInterstitial = nil
    }
    
    func forgetCurrentInterstitial() {
        if let _ = embeddedInterstitial {
            embeddedInterstitial = nil
        }  else if let _ = oxbProxyInterstitial {
            oxbProxyInterstitial = nil
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
