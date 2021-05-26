//
//  MoPubInterstitialAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

public class MoPubInterstitialAdUnit : MoPubBaseInterstitialAdUnit {
    
    // MARK: - Public Properties
    
    public var adFormat: PBMAdFormat {
        get { adUnitConfig.adFormat }
        set { adUnitConfig.adFormat = newValue }
    }
    
    public var additionalSizes: [NSValue]? {
        get { adUnitConfig.additionalSizes?.map { NSValue(cgSize: $0) } }
        set { adUnitConfig.additionalSizes = newValue?.compactMap { $0.cgSizeValue } }
    }
    
    // MARK: - Public Methods
    
    public override convenience init(configId: String) {
        self.init(configId: configId, minSizePercentage: nil)
    }
    
    public init(configId: String, minSizePercentage: CGSize?) {
        super.init(configId: configId)
        
        if let size = minSizePercentage {
            adUnitConfig.minSizePerc = NSValue(cgSize: size)
        }
    }
    
    // MARK: - Computed Properties
    
    public override var configId: String {
        adUnitConfig.configID
    }
}
