//
//  PBMMoPubNativeAdUnit.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMFetchDemandResult.h"
#import "PBMNativeAdUnit.h"
#import "PBMMoPubUtils.h"

@class PBMNativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PBMMoPubNativeAdUnit : NSObject

//This is an MPNativeAdRequestTargeting object with properties keywords and localExtra
//But we can't use it indirectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<PBMMoPubAdObjectProtocol> adObject;
@property (nonatomic, copy, nullable) void (^completion)(PBMFetchDemandResult);

@property (nonatomic, strong) PBMNativeAdUnit *nativeAdUnit;

@property (nonatomic, copy, readonly) NSString *configId;
@property (atomic, copy, readonly) PBMNativeAdConfiguration *nativeAdConfig;

// MARK: - Lifecycle
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration;

// MARK: - Ad Request
- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(PBMFetchDemandResult))completion;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
