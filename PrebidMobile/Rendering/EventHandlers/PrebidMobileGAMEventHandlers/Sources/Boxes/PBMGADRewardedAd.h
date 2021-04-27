//
//  PBMGADRewardedAd.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "PBMGAMRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMGADRewardedAd : NSObject

@property (nonatomic, class, readonly) BOOL classesFound;
@property (nonatomic, strong, readonly) NSObject *boxedRewardedAd;

// Boxed properties
@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic, weak, nullable) id<GADAdMetadataDelegate> adMetadataDelegate;
@property (nonatomic, readonly, nullable) NSDictionary<GADAdMetadataKey, id> *adMetadata;
@property (nonatomic, readonly, nullable) NSObject *reward;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdUnitID:(nonnull NSString *)adUnitID NS_DESIGNATED_INITIALIZER;

- (void)loadRequest:(nullable PBMGAMRequest *)request
    completionHandler:(nullable GADRewardedAdLoadCompletionHandler)completionHandler;

- (void)presentFromRootViewController:(UIViewController *)viewController
                             delegate:(id<GADFullScreenContentDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
