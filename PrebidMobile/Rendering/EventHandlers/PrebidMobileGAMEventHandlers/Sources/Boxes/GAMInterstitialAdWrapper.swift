//
//  GAMInterstitialAdWrapper.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GAMInterstitialAdWrapper {
    
    static var classesValidated: Bool?
    
    var interstitialAd: GAMInterstitialAd?
    
    let adUnitID: String
    
    public static var classesFound: Bool {
        if let res = classesValidated {
            return res;
        }
        
        classesValidated = GAMInterstitialAdWrapper.findClasses()
        return classesValidated ?? false
    }
    
    init?(adUnitID: String) {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        self.adUnitID = adUnitID
    }
    
    // MARK: Public Properties
    
    public var fullScreenContentDelegate: GADFullScreenContentDelegate? {
        set {
            interstitialAd?.fullScreenContentDelegate = newValue
        }
        
        get {
            interstitialAd?.fullScreenContentDelegate
        }
    }
    
    public var appEventDelegate: GADAppEventDelegate? {
        set {
            interstitialAd?.appEventDelegate = newValue
        }
        
        get {
            interstitialAd?.appEventDelegate
        }
    }
    
    // MARK: Public Methods
    
    public func load(request: GAMRequestWrapper,
                     completion: @escaping (GAMInterstitialAdWrapper, Error?) -> Void) {
        
        GAMInterstitialAd.load(withAdManagerAdUnitID: adUnitID,
                               request: request.boxedRequest,
                               completionHandler: { [weak self] ad, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                completion(self, error)
                return
            }
            
            self.interstitialAd = ad
            completion(self, nil)
        })
    }
    
    public func present(from rootViewController: UIViewController) {
        interstitialAd?.present(fromRootViewController: rootViewController)
    }
    
    static func findClasses() -> Bool {
        
        guard let _ = NSClassFromString("GAMInterstitialAd"),
              let _ = NSProtocolFromString("GADAppEventDelegate") else {
            return false;
        }
        
        let selector = NSSelectorFromString("loadWithAdManagerAdUnitID:request:completionHandler:")
        if GAMInterstitialAd.responds(to: selector) == false {
            return false
        }
        
        let testClass = GAMInterstitialAd.self
        
        let selectors = [
            #selector(getter: GAMInterstitialAd.fullScreenContentDelegate),
            #selector(setter: GAMInterstitialAd.fullScreenContentDelegate),
            #selector(getter: GAMInterstitialAd.appEventDelegate),
            #selector(setter: GAMInterstitialAd.appEventDelegate),

            #selector(GAMInterstitialAd.present(fromRootViewController:)),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
    
}
