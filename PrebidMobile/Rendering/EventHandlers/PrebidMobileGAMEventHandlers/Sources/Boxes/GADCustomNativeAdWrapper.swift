//
//  GADCustomNativeAdWrapper.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GADCustomNativeAdWrapper {
    
    static var classesValidated: Bool?
    
    let customNativeAd: GADCustomNativeAd
    
    // MARK: - Public Methods
    
    init(customNativeAd: GADCustomNativeAd) {
        self.customNativeAd = customNativeAd
    }

    // MARK: - Public (own) properties

    public static var classesFound: Bool {
        if let res = classesValidated {
            return res;
        }
        
        classesValidated = GADCustomNativeAdWrapper.findClasses()
        return classesValidated ?? false
    }
    
    public var boxedAd: GADCustomNativeAd?  {
        customNativeAd
    }
    
    // MARK: - Public (Boxed) Methods
    
    public func string(forKey: String) -> String? {
        customNativeAd.string(forKey: forKey)
    }

    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GADNativeCustomTemplateAd") else {
            return false;
        }
        
        let testClass = GADCustomNativeAd.self
        
        let selectors = [
            #selector(GADCustomNativeAd.string(forKey:)),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
}
