//
//  PBMNativeAdUnit.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBaseAdUnit.h"

#import "PBMNativeAd.h"
#import "PBMNativeAdHandler.h"

@class NativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdUnit : PBMBaseAdUnit

// MARK: - Required properties
@property (nonatomic, copy, readonly) NSString *configId; // inherited from PBMBaseAdUnit
@property (atomic, copy, readonly) NativeAdConfiguration *nativeAdConfig;

// MARK: - Lifecycle
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(NativeAdConfiguration *)nativeAdConfiguration;

// MARK: - Get Native Ad
- (void)fetchDemandWithCompletion:(PBMFetchDemandCompletionHandler)completion;  // inherited from PBMBaseAdUnit

@end

NS_ASSUME_NONNULL_END
