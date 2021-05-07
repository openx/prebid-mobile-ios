//
//  PBMNativeAdConfiguration+Testing.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension Array where Self.Element == PBMNativeAsset {
    static let defaultNativeRequestAssets: [PBMNativeAsset] = [
        {
            let title = NativeAssetTitle(length: 90)
            title.required = true
            return title
        }(),
        {
            let icon = NativeAssetImage()
            icon.widthMin = 50
            icon.heightMin = 50
            icon.required = true
            icon.imageType = NSNumber(value: PBMImageAssetType.icon.rawValue)
            return icon
        }(),
        {
            let image = NativeAssetImage()
            image.widthMin = 150
            image.heightMin = 50
            image.required = true
            image.imageType = NSNumber(value: PBMImageAssetType.main.rawValue)
            return image
        }(),
        {
            let desc = NativeAssetData(dataType: .desc)
            desc.required = true
            return desc
        }(),
        {
            let cta = NativeAssetData(dataType: .ctaText)
            cta.required = true
            return cta
        }(),
        {
            let sponsored = NativeAssetData(dataType: .sponsored)
            sponsored.required = true
            return sponsored
        }(),
    ]
}

// TODO: additional parameters for trackers, context, etc. (?)
extension PBMNativeAdConfiguration {
    convenience init(testConfigWithAssets assets: [PBMNativeAsset]) {
        self.init(assets: assets)
        
        self.eventtrackers = [
            PBMNativeEventTracker(event: .impression,
                                  methods: [
                                    PBMNativeEventTrackingMethod.img,
                                    .JS,
                                  ].map { NSNumber(value: $0.rawValue) }),
        ]
        
        self.context = .socialCentric
        self.contextsubtype = .social
        self.plcmttype = .feedGridListing
    }
}
