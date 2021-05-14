//
//  PBMMoPubNativeAdUtils.h
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import <MoPubSDK/MoPub.h>

@import PrebidMobileRendering;

NS_ASSUME_NONNULL_BEGIN

@interface PrebidMoPubNativeAdUtils : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedUtils;

- (void)prepareAdObject:(id)adObject;

- (void)findNativeAdIn:(MPNativeAd *)nativeAd nativeAdDetectionListener:(NativeAdDetectionListener *)nativeAdDetectionListener;

@end

NS_ASSUME_NONNULL_END
