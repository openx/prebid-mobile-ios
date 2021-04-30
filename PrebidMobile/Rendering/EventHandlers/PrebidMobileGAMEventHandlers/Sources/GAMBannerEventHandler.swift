//
//  GAMBannerEventHandler.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileRendering

class GAMBannerEventHandler : NSObject, PBMBannerEventHandler {
    
    let adUnitID: String
    
    init(adUnitID: String, adSizes: [NSValue]) {
        self.adUnitID = adUnitID
        self.adSizes = adSizes
    }
    
    // MARK: PBMBannerEventHandler
    
    var loadingDelegate: PBMBannerEventLoadingDelegate?
    
    var interactionDelegate: PBMBannerEventInteractionDelegate?
    
    var adSizes: [NSValue]
    
    var isCreativeRequiredForNativeAds: Bool {
        false
    }
    
    func requestAd(with bidResponse: PBMBidResponse?) {
        // TODO
    }
    
    
}


