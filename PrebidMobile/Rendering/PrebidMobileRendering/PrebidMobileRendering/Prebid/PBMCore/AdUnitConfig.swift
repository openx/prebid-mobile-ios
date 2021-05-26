//
//  AdUnitConfig.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

public let refreshIntervalMin: TimeInterval  = 15
public let refreshIntervalMax: TimeInterval = 120
public let refreshIntervalDefault: TimeInterval  = 60

class AdUnitConfig: NSObject, NSCopying {
    
    // MARK: - Properties
       
    var configID: String
    
    var adFormat: PBMAdFormat {
        didSet {
            self.updateAdFormat()
        }
    }
    
    var nativeAdConfiguration: NativeAdConfiguration? {
        get { self.nativeAdConfiguration }
        set {
            self.nativeAdConfiguration = newValue?.copy() as? NativeAdConfiguration
            updateAdFormat()
        }
    }
    
    var adSize: CGSize
    var minSizePerc: NSValue?
    
    var adPosition = PBMAdPosition.undefined
        
    // MARK: - Computed Properties
    
    var additionalSizes: [CGSize]? {
        get { sizes }
        set { sizes = newValue }
    }
    
    var refreshInterval: TimeInterval {
        get { self.refreshInterval }
        set {
            if adFormat == .video {
                PBMLog.warn("'refreshInterval' property is not assignable for Outstream Video ads")
                return
            }
            
            if newValue < 0 {
                self.refreshInterval  = 0
            } else {
                let lowerClamped = max(newValue, refreshIntervalMin);
                let doubleClamped = min(lowerClamped, refreshIntervalMax);
                
                self.refreshInterval = doubleClamped;
                
                if self.refreshInterval != newValue {
                    PBMLog.warn("The value \(newValue) is out of range [\(refreshIntervalMin);\(refreshIntervalMax)]. The value \(self.refreshInterval) will be used")
                }
            }
        }
    }
    
    var isInterstitial: Bool {
        get { adConfiguration.isInterstitialAd }
        set { adConfiguration.isInterstitialAd = newValue }
    }
        
    var isOptIn: Bool {
        get { adConfiguration.isOptIn }
        set { adConfiguration.isOptIn = newValue }
    }
    
    var videoPlacementType: PBMVideoPlacementType {
        get { adConfiguration.videoPlacementType }
        set { adConfiguration.videoPlacementType = newValue }
    }
    
    // MARK: - Public Methods
    
    convenience init(configID: String) {
        self.init(configID: configID, adSize: CGSize.zero)
    }
    
    init(configID: String, adSize: CGSize) {
        self.configID = configID
        self.adSize = adSize
        
        adFormat = .display
        
        adConfiguration.autoRefreshDelay = 0
        adConfiguration.size = adSize
    }
    
    public func addContextData(_ data: String, forKey key: String) {
        if extensionData[key] == nil {
            extensionData[key] = Set<String>()
        }
        
        extensionData[key]?.insert(data)
    }
    
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        extensionData[key] = data
    }
    
    public func removeContextDate(forKey key: String) {
        extensionData.removeValue(forKey: key)
    }
    
    public func clearContextData() {
        extensionData.removeAll()
    }
    
    // MARK: - Private Properties
    
    var extensionData = [String : Set<String>]()
    
    var sizes: [CGSize]?
    
    let adConfiguration = PBMAdConfiguration();
    
    var contextDataDictionary: [String : [String]] {
        extensionData.mapValues { Array($0) }
    }
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let clone = AdUnitConfig(configID: self.configID, adSize: self.adSize)
        
        clone.adFormat = self.adFormat
        clone.adConfiguration.adFormat = self.adConfiguration.adFormat
        clone.adConfiguration.isInterstitialAd = self.adConfiguration.isInterstitialAd
        clone.adConfiguration.isOptIn = self.adConfiguration.isOptIn
        clone.adConfiguration.videoPlacementType = self.adConfiguration.videoPlacementType
        clone.nativeAdConfiguration = self.nativeAdConfiguration
        clone.sizes = sizes
        clone.refreshInterval = self.refreshInterval
        clone.minSizePerc = self.minSizePerc
        clone.extensionData = self.extensionData.merging(clone.extensionData) { $1 }
        clone.adPosition = self.adPosition
        
        return clone
    }
    
    // MARK: - Private Methods
    
    private func getInternalAdFormat() -> PBMAdFormatInternal {
        if let _ = nativeAdConfiguration {
            return .nativeInternal
        } else {
            switch adFormat {
                case .display   : return .displayInternal
                case .video     : return .videoInternal
            }
        }
    }
    
    private func updateAdFormat() {
        let newAdFormat = getInternalAdFormat()
        if adConfiguration.adFormat == newAdFormat {
            return
        }
        
        self.adConfiguration.adFormat = newAdFormat
        self.refreshInterval = ((newAdFormat == .videoInternal) ? 0 : refreshIntervalDefault);
    }
}
