//
//  OXAApolloNativeAdAdapter.h
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <MoPub/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@class PBMNativeAd;

@interface OXAMoPubNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

@property (nonatomic, strong, readonly) PBMNativeAd *nativeAd;

- (instancetype)initWithOXANativeAd:(PBMNativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
