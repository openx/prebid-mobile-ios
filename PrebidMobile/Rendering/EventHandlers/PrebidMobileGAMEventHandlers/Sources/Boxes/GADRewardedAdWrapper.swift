//
//  PrebidGADRewardedAd.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GADRewardedAdWrapper {
    
    static var classesValidated: Bool?
    
    var rewardedAd: GADRewardedAd?
    
    let adUnitID: String
    
    public static var classesFound: Bool {
        if let res = classesValidated {
            return res;
        }
        
        classesValidated = GADRewardedAdWrapper.findClasses()
        return classesValidated ?? false
    }
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    // MARK: Public Properties
    
    public var adMetadata: [GADAdMetadataKey : Any]? {
        rewardedAd?.adMetadata
    }
    
    public var adMetadataDelegate: GADAdMetadataDelegate? {
        set {
            rewardedAd?.adMetadataDelegate = newValue
        }
        
        get {
            rewardedAd?.adMetadataDelegate
        }
    }
    
    public var reward: GADAdReward? {
        rewardedAd?.adReward
    }
    
    // MARK: Public Methods
    
    public func load(request: GAMRequestWrapper,
                     completion: @escaping (GADRewardedAdWrapper?, Error?) -> Void) {
        GADRewardedAd.load(withAdUnitID: adUnitID,
                           request:request.boxedRequest,
                           completionHandler: { [weak self] (ad, error)  in
                            guard let self = self else {
                                return
                            }
                            
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            self.rewardedAd = ad
                            completion(self, nil)
                           })
        
        
    }
    
    public func present(from rootViewController: UIViewController,
                        userDidEarnRewardHandler: @escaping () -> Void) {
        
        rewardedAd?.present(fromRootViewController: rootViewController,
                            userDidEarnRewardHandler: userDidEarnRewardHandler)
    }
    
    static func findClasses() -> Bool {
        
        guard let _ = NSClassFromString("GADRewardedAd"),
              let _ = NSClassFromString("GADAdReward"),
              let _ = NSProtocolFromString("GADAdMetadataDelegate") else {
            return false;
        }
        
        let selector = NSSelectorFromString("loadWithAdUnitID:request:completionHandler:")
        if GADRewardedAd.responds(to: selector) == false {
            return false
        }
        
        let testClass = GADRewardedAd.self
        
        let selectors = [
            #selector(getter: GADRewardedAd.adMetadataDelegate),
            #selector(setter: GADRewardedAd.adMetadataDelegate),
            #selector(getter: GADRewardedAd.adMetadata),
            #selector(getter: GADRewardedAd.adReward),
            #selector(GADRewardedAd.present(fromRootViewController:userDidEarnRewardHandler:)),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
    
}
