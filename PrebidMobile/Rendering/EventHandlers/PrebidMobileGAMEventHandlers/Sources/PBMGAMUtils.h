//
//  PBMGAMUtils.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import <PrebidMobileRendering/PBMDemandResponseInfo.h>
#import <PrebidMobileRendering/PBMNativeAdDetectionListener.h>

@class GAMRequest;
@class GADCustomNativeAd;
@class GADNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface PBMGAMUtils : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedUtils;

- (void)prepareRequest:(GAMRequest *)request
    demandResponseInfo:(PBMDemandResponseInfo *)demandResponseInfo;

- (void)findNativeAdInCustomTemplateAd:(GADCustomNativeAd *)nativeCustomTemplateAd
             nativeAdDetectionListener:(PBMNativeAdDetectionListener *)nativeAdDetectionListener;

- (void)findNativeAdInUnifiedNativeAd:(GADNativeAd *)unifiedNativeAd
            nativeAdDetectionListener:(PBMNativeAdDetectionListener *)nativeAdDetectionListener;

@end

NS_ASSUME_NONNULL_END
