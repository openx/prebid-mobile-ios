//
//  NativeAdVideo.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAdVideo: PBMNativeAdAsset {
    
    /// Media data describing this asset
    @objc private(set) public var mediaData: MediaData!

    @objc public init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset, nativeAdHooks: PBMNativeAdMediaHooks) throws {
        guard let _ = nativeAdMarkupAsset.video else {
            throw PBMNativeAdAssetBoxingError.noVideoInsideNativeAdMarkupAsset
        }
        
        mediaData = MediaData(mediaAsset: nativeAdMarkupAsset, nativeAdHooks: nativeAdHooks)
        
        try super.init(nativeAdMarkupAsset: nativeAdMarkupAsset)
    }
    
    private override init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset) throws {
        try super.init(nativeAdMarkupAsset: nativeAdMarkupAsset)
    }
}
