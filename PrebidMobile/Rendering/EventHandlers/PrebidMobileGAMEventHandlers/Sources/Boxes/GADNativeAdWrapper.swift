//
//  GADNativeAdWrapper.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GADNativeAdWrapper {
    
    static var classesValidated: Bool?
    
    let nativeAd: GADNativeAd

    // MARK: - Public (own) properties

    public static var classesFound: Bool {
        if let res = classesValidated {
            return res;
        }
        
        classesValidated = GAMBannerViewWrapper.findClasses()
        return classesValidated ?? false
    }
    
    public var boxedAd: GADNativeAd?  {
        nativeAd
    }
    
    // MARK: - Public (Boxed) Properties
    
    public var headline: String? {
        nativeAd.headline
    }
    
    public var callToAction: String? {
        nativeAd.callToAction
    }
    
    public var body: String? {
        nativeAd.body
    }
    
    public var starRating: NSDecimalNumber? {
        nativeAd.starRating
    }
    
    public var store: String? {
        nativeAd.store
    }
    
    public var price: String? {
        nativeAd.price
    }
    
    public var advertiser: String? {
        nativeAd.advertiser
    }
    
    // MARK: - Public Methods
    
    init(nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
    }

    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GADNativeAd") else {
            return false;
        }
        
        let testClass = GADNativeAd.self
        
        let selectors = [
            #selector(getter: GADNativeAd.headline),
            #selector(getter: GADNativeAd.callToAction),
            #selector(getter: GADNativeAd.body),
            #selector(getter: GADNativeAd.starRating),
            #selector(getter: GADNativeAd.store),
            #selector(getter: GADNativeAd.price),
            #selector(getter: GADNativeAd.advertiser)
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
}
