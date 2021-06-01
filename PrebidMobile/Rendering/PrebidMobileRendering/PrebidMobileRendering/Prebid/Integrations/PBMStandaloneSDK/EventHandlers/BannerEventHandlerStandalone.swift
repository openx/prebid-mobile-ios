//
//  BannerEventHandlerStandalone.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class BannerEventHandlerStandalone: NSObject, PBMBannerEventHandler {
    
    public var loadingDelegate: BannerEventLoadingDelegate?
    public var interactionDelegate: PBMBannerEventInteractionDelegate?
    
    public var adSizes: [NSValue] = []
    
    public var isCreativeRequiredForNativeAds: Bool {
        true
    }
    
    public func requestAd(with bidResponse: BidResponse?) {
        loadingDelegate?.prebidDidWin()
    }
    
    
}
