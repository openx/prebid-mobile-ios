//
//  OXARewardedEventInteractionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OXAInterstitialEventInteractionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 The rewarded custom event delegate. It is used to inform ad server events back to the OpenWrap SDK
 */
@protocol OXARewardedEventInteractionDelegate <OXAInterstitialEventInteractionDelegate>

/*!
 @abstract Call this when the ad server SDK decides the use has earned reward
 */
- (void)userDidEarnReward:(nullable NSObject *)reward;

@end

NS_ASSUME_NONNULL_END