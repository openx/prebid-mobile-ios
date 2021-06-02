//
//  PBMBaseInterstitialAdUnit+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMInterstitialEventInteractionDelegate.h"

@class AdUnitConfig;
@class BidResponse;
@class InterstitialController;
@protocol RewardedEventLoadingDelegate;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMBaseInterstitialAdUnitProtocol <NSObject>

- (void)interstitialControllerDidCloseAd:(InterstitialController *)interstitialController;

- (void)callDelegate_didReceiveAd;
- (void)callDelegate_didFailToReceiveAdWithError:(NSError *)error;
- (void)callDelegate_willPresentAd;
- (void)callDelegate_didDismissAd;
- (void)callDelegate_willLeaveApplication;
- (void)callDelegate_didClickAd;

- (BOOL)callEventHandler_isReady;
- (void)callEventHandler_setLoadingDelegate:(id<RewardedEventLoadingDelegate>)loadingDelegate;
- (void)callEventHandler_setInteractionDelegate;
- (void)callEventHandler_requestAdWithBidResponse:(nullable BidResponse *)bidResponse;
- (void)callEventHandler_showFromViewController:(nullable UIViewController *)controller;
- (void)callEventHandler_trackImpression;

@end


NS_ASSUME_NONNULL_END
