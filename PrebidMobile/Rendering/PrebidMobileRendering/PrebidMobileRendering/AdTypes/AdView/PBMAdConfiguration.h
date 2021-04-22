//
//  PBMAdConfiguration.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMCreativeClickHandlerBlock.h"
#import "PBMVideoPlacementType.h"
#import "PBMAdFormatInternal.h"
#import "PBMAutoRefreshCountConfig.h"
#import "PBMInterstitialLayout.h"

/**
 Contains all the data needed to load an ad.
 */
NS_ASSUME_NONNULL_BEGIN

@interface PBMAdConfiguration : NSObject<PBMAutoRefreshCountConfig>

#pragma mark - Request

@property (nonatomic, assign) PBMAdFormatInternal adFormat;

/**
 Indicates whether the ad is native.
 It is used to perform some naive ad-specific actions, f.e. prevent start OM
 tracking for a native ad with video
 */
@property (nonatomic, assign) BOOL isNative;

/**
 Placement type for the video.
 */
@property (nonatomic, assign) PBMVideoPlacementType videoPlacementType;


#pragma mark - Interstitial

/**
 Whether or not this ad configuration is intended to represent an intersitial ad.

 Setting this to @c YES will disable auto refresh.
 */
@property (nonatomic, assign) BOOL isInterstitialAd;

/**
 Whether or not this ad configuration is intended to represent an ad as an intersitial one (regardless of original designation).
 Overrides `isInterstitialAd`

 Setting this to @c YES will disable auto refresh.
 */
@property (nonatomic, strong, nullable) NSNumber *forceInterstitialPresentation;

/**
 Whether or not this ad configuration is intended to represent an intersitial ad.
 Returns the effective result by combining `isInterstitialAd` and `forceInterstitialPresentation`
 */
@property (nonatomic, readonly) BOOL presentAsInterstitial;

/**
 Interstitial layout
 */
@property (nonatomic, assign) PBMInterstitialLayout interstitialLayout;

/**
 Size for the ad.
 */
@property (nonatomic, assign) CGSize size;

/**
 Sets a video interstitial ad unit as an opt-in video
 */
@property (nonatomic, assign) BOOL isOptIn;

/**
 Indicates whether the ad is built-in video e.g. 300x250.
 */
@property (nonatomic, assign) BOOL isBuiltInVideo;

#pragma mark - Impression Tracking

@property (nonatomic, assign) NSTimeInterval pollFrequency;

@property (nonatomic, assign) NSUInteger viewableArea;

@property (nonatomic, assign) NSTimeInterval viewableDuration;

#pragma mark - Other

/**
 If provided, this block will be called instead of directly attempting to handle clickthrough event.
 */
@property (nonatomic, copy, nullable) PBMCreativeClickHandlerBlock clickHandlerOverride;

@end
NS_ASSUME_NONNULL_END
