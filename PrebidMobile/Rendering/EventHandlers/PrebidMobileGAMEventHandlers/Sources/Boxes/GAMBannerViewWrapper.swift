//
//  GAMBannerViewWrapper.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GAMBannerViewWrapper {
    
    // MARK: - Private Properties
    
    private static var classesValidated: Bool?
    
    private static var classesFound = GAMBannerViewWrapper.findClasses()
    
    // MARK: - Public Properties
    
    let banner = GAMBannerView()
    
    // MARK: - Public Methods
        
    public init?() {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
    }
    
    // MARK: - Public Wrappers (Properties)

    public var adUnitID: String? {
        set {
            banner.adUnitID = newValue
        }
        
        get {
            banner.adUnitID
        }
    }
    
    public var validAdSizes: [NSValue]? {
        set {
            banner.validAdSizes = newValue
        }
        
        get {
            banner.validAdSizes
        }
    }
    public var rootViewController: UIViewController? {
        set {
            banner.rootViewController = newValue
        }
        
        get {
            banner.rootViewController
        }
    }
    
    public var delegate: GADBannerViewDelegate? {
        set {
            banner.delegate = newValue
        }
        
        get {
            banner.delegate
        }
    }
    
    public var appEventDelegate: GADAppEventDelegate? {
        set {
            banner.appEventDelegate = newValue
        }
        
        get {
            banner.appEventDelegate
        }
    }
    
    public var adSizeDelegate: GADAdSizeDelegate? {
        set {
            banner.adSizeDelegate = newValue
        }
        
        get {
            banner.adSizeDelegate
        }
    }
    
    public var enableManualImpressions: Bool {
        set  {
            banner.enableManualImpressions = newValue
        }
        
        get {
            banner.enableManualImpressions
        }
    }
    
    public var adSize : GADAdSize {
        set {
            banner.adSize = newValue
        }
        
        get {
            banner.adSize
        }
    }
        
    // MARK: - Public Wrappers (Properties)

    public func load(_ request: GAMRequestWrapper) {
        banner.load(request.request)
    }

    public func recordImpression() {
        banner.recordImpression()
    }
    
    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GAMBannerView"),
              let _ = NSProtocolFromString("GADBannerViewDelegate"),
              let _ = NSProtocolFromString("GADAppEventDelegate"),
              let _ = NSProtocolFromString("GADAdSizeDelegate") else {
            return false;
        }
        
        let testClass = GAMBannerView.self
        
        let selectors = [
            #selector(getter: GAMBannerView.adUnitID),
            #selector(setter: GAMBannerView.adUnitID),
            
            #selector(getter: GAMBannerView.validAdSizes),
            #selector(setter: GAMBannerView.validAdSizes),
            
            #selector(getter: GAMBannerView.rootViewController),
            #selector(setter: GAMBannerView.rootViewController),
            
            #selector(getter: GAMBannerView.delegate),
            #selector(setter: GAMBannerView.delegate),
            
            #selector(getter: GAMBannerView.appEventDelegate),
            #selector(setter: GAMBannerView.appEventDelegate),
            
            #selector(getter: GAMBannerView.adSizeDelegate),
            #selector(setter: GAMBannerView.adSizeDelegate),
            
            #selector(getter: GAMBannerView.enableManualImpressions),
            #selector(setter: GAMBannerView.enableManualImpressions),
            
            #selector(getter: GAMBannerView.adSize),
            #selector(setter: GAMBannerView.adSize),
            
            #selector(GAMBannerView.load(_:)),
            #selector(GAMBannerView.recordImpression),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }

}
