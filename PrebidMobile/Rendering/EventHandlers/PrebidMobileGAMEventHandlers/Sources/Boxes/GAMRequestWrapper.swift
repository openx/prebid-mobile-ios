//
//  GAMRequestWrapper.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GAMRequestWrapper {
    
    static var classesValidated: Bool?
    
    let request: GAMRequest
    
    // MARK: - Public (boxed) properties
    
    var customTargeting: [String : String]? {
        set {
            request.customTargeting = newValue
        }
        
        get {
            request.customTargeting
        }
    }

    // MARK: - Public (own) properties

    public static var classesFound: Bool {
        if let res = classesValidated {
            return res;
        }
        
        classesValidated = GAMBannerViewWrapper.findClasses()
        return classesValidated ?? false
    }
    
    public var boxedRequest: GAMRequest?  {
        request
    }
    
    // MARK: - Public Methods
    
    init?() {
        if !GAMRequestWrapper.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        request = GAMRequest()
    }
    
    init?(request: GAMRequest) {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        self.request = request
    }
 
    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GAMRequest") else {
            return false;
        }
        
        let testClass = GAMRequest.self
        
        let selectors = [
            #selector(getter: GAMRequest.customTargeting),
            #selector(setter: GAMRequest.customTargeting),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
}
