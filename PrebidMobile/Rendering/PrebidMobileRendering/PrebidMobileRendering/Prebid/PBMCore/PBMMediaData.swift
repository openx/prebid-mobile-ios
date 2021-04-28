//
//  PBMMediaDataTTT.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objcMembers public class PBMMediaData: NSObject {
    
    public let mediaAsset: PBMNativeAdMarkupAsset
    public let nativeAdHooks: PBMNativeAdMediaHooks
    
    public init(mediaAsset: PBMNativeAdMarkupAsset, nativeAdHooks: PBMNativeAdMediaHooks) {
        self.mediaAsset = mediaAsset
        self.nativeAdHooks = nativeAdHooks
    }
}
