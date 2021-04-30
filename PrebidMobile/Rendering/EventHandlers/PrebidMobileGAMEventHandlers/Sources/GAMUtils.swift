//
//  GAMUtils.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileRendering

fileprivate let LOCAL_CACHE_EXPIRATION_INTERVAL: TimeInterval = 3600;
fileprivate let PREBID_KEYWORD_PREFIX = "hb_"

public class GAMUtils {
    
    private let localCache: PBMLocalResponseInfoCache!
    
    private init() {
        localCache = PBMLocalResponseInfoCache(expirationInterval: LOCAL_CACHE_EXPIRATION_INTERVAL)
    }
    
    public static let shared = GAMUtils()
    
    public func prepareRequest(_ request: GAMRequest,
                        demandResponseInfo: PBMDemandResponseInfo)  {
        if !GAMRequestWrapper.classesFound {
            return
        }
        
        let localCacheID = localCache.store(demandResponseInfo)
        let boxedRequest = GAMRequestWrapper(gamRequest: request)
        
        var mergedTargeting = getPrebidTargeting(from: boxedRequest)
        
        if let bidTargeting = demandResponseInfo.bid?.targetingInfo {
            mergedTargeting.merge(bidTargeting) { $1 }
        }
        
        mergedTargeting[Constantns.LOCAL_CACHE_ID_TARGETING_KEY] = localCacheID
        
        boxedRequest.customTargeting = mergedTargeting
    }
    
    public func findNativeAd(for nativeAd: GADNativeAd,
                      nativeAdDetectionListener: PBMNativeAdDetectionListener) {
        
        if GADNativeAdWrapper.classesFound == false {
            nativeAdDetectionListener.onNativeAdInvalid?(PBMGAMError.gamClassesNotFound)
            return
        }
       
        let wrappedAd = GADNativeAdWrapper(nativeAd: nativeAd)
        
        findNativeAd(flagLookupBlock: {
            findPrebidFlagInNativeAd(wrappedAd)
        }, localCacheIDExtractor: {
            localCacheIDFromNativeAd(wrappedAd)
        }, nativeAdDetectionListener: nativeAdDetectionListener)
    }
    
    public func findCustomNativeAd(for customNativeAd: GADCustomNativeAd,
                            nativeAdDetectionListener: PBMNativeAdDetectionListener) {
        
        if PBMGADCustomNativeAd.classesFound == false {
            nativeAdDetectionListener.onNativeAdInvalid?(PBMGAMError.gamClassesNotFound)
            return
        }
        
        let wrappedAd = PBMGADCustomNativeAd(customNativeAd: customNativeAd)
        findNativeAd(flagLookupBlock: {
            findCreativeFlagInCustomNativeAd(wrappedAd)
        }, localCacheIDExtractor: {
            localCacheIDFromCustomNativeAd(wrappedAd)
        }, nativeAdDetectionListener: nativeAdDetectionListener)
    }
    
    // MARK: Private Methods
    
    private func getPrebidTargeting(from request: GAMRequestWrapper) -> [String: String] {
        if let requestTargeting = request.customTargeting {
            return requestTargeting.filter { $0.key.hasPrefix(PREBID_KEYWORD_PREFIX)}
        }
        
        return [String : String]()
    }
    
    private func findNativeAd(flagLookupBlock: () -> Bool,
                              localCacheIDExtractor: () -> String?,
                              nativeAdDetectionListener: PBMNativeAdDetectionListener) {
        
        if flagLookupBlock() == false {
            nativeAdDetectionListener.onPrimaryAdWin?()
            return
        }
        
        guard let localCacheID = localCacheIDExtractor() else {
            nativeAdDetectionListener.onNativeAdInvalid?(PBMGAMError.noLocalCacheID)
            return
        }
        
        guard let cacheResponse = localCache.getStoredResponseInfo(localCacheID) else {
            nativeAdDetectionListener.onNativeAdInvalid?(PBMGAMError.invalidLocalCacheID)
            return
        }
        
        cacheResponse.getNativeAd { ad in
            guard let nativeAd = ad else {
                nativeAdDetectionListener.onNativeAdInvalid?(PBMGAMError.invalidNativeAd)
                return
            }
            
            nativeAdDetectionListener.onNativeAdLoaded?(nativeAd)
        }
    }
    
    // MARK: UnifiedNativeAd decomposition

    private func findPrebidFlagInNativeAd(_ nativeAd: GADNativeAdWrapper) -> Bool {
        nativeAd.body == Constantns.PREBID_CREATIVE_FLAG_KEY
    }
    
    private func localCacheIDFromNativeAd(_ nativeAd: GADNativeAdWrapper) -> String? {
        nativeAd.callToAction;
    }

    // MARK: NativeCustomTemplateAd decomposition

    private func findCreativeFlagInCustomNativeAd(_ customNativeAd: PBMGADCustomNativeAd) -> Bool {
        if let isPrebidCreativeVar = customNativeAd.string(forKey: Constantns.PREBID_CREATIVE_FLAG_KEY),
           isPrebidCreativeVar == Constantns.CREATIVE_FLAG_VALUE {
            return true;
        }

        return false;
    }

    private func localCacheIDFromCustomNativeAd(_ customNativeAd: PBMGADCustomNativeAd) -> String? {
        customNativeAd.string(forKey: Constantns.LOCAL_CACHE_ID_TARGETING_KEY)
    }
}
