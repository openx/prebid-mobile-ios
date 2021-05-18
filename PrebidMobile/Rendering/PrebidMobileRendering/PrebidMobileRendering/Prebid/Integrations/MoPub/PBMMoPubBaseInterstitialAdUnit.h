//
//  PBMMoPubBaseInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMFetchDemandResult.h"
#import "PBMMoPubUtils.h"
#import "PBMAdUnitConfig.h"


@class PBMBidRequester;

NS_ASSUME_NONNULL_BEGIN

@interface PBMMoPubBaseInterstitialAdUnit : NSObject

@property (nonatomic, strong, nonnull, readonly) PBMAdUnitConfig *adUnitConfig;

@property (nonatomic, copy, readonly) NSString *configId;

@property (nonatomic, strong, nullable) PBMBidRequester *bidRequester;

//This is an MPInterstitialAdController object
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<PBMMoPubAdObjectProtocol>adObject;
@property (nonatomic, copy, nullable) void (^completion)(PBMFetchDemandResult);

- (instancetype)initWithConfigId:(NSString *)configId;

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(PBMFetchDemandResult))completion;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
