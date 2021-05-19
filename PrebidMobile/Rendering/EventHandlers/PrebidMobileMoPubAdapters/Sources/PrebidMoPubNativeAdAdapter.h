//
//  PBMApolloNativeAdAdapter.h
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <MoPubSDK/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@class NativeAd;

@interface PrebidMoPubNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

@property (nonatomic, strong, readonly) NativeAd *nativeAd;

- (instancetype)initWithPBMNativeAd:(NativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
