//
//  OXAAdLoaderFlowDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OXAAdLoaderProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol OXAAdLoaderFlowDelegate <NSObject>

- (void)adLoader:(id<OXAAdLoaderProtocol>)adLoader loadedPrimaryAd:(id)adObject adSize:(nullable NSValue *)adSize;
- (void)adLoader:(id<OXAAdLoaderProtocol>)adLoader failedWithPrimarySDKError:(nullable NSError *)error;

- (void)adLoaderDidWinPrebid:(id<OXAAdLoaderProtocol>)adLoader;

- (void)adLoaderLoadedPrebidAd:(id<OXAAdLoaderProtocol>)adLoader;
- (void)adLoader:(id<OXAAdLoaderProtocol>)adLoader failedWithPrebidError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
