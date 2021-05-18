//
//  OXAMoPubInterstitialAdUnit+TestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@protocol PBMServerConnectionProtocol;

@interface MoPubInterstitialAdUnit ()
- (void)fetchDemandWithObject:(NSObject *)adObject
                   connection:(id<PBMServerConnectionProtocol>)connection
             sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                    targeting:(PBMTargeting *)targeting
                   completion:(void (^)(PBMFetchDemandResult))completion;
@end
