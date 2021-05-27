//
//  PBMBidRequesterFactory.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidRequesterFactory.h"

#import "PBMBidRequester.h"
#import "PBMTargeting.h"
#import "PBMServerConnection.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@implementation PBMBidRequesterFactory

+ (PBMBidRequesterFactoryBlock)requesterFactoryWithSingletons {
    return [self requesterFactoryWithConnection:[PBMServerConnection singleton]
                               sdkConfiguration:[PrebidRenderingConfig shared]
                                      targeting:[PBMTargeting shared]];
}

+ (PBMBidRequesterFactoryBlock)requesterFactoryWithConnection:(id<PBMServerConnectionProtocol>)connection
                                             sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                                                    targeting:(PBMTargeting *)targeting
{
    return ^id<PBMBidRequesterProtocol> (AdUnitConfig * adUnitConfig) {
        return [[PBMBidRequester alloc] initWithConnection:connection
                                          sdkConfiguration:sdkConfiguration
                                                 targeting:targeting
                                       adUnitConfiguration:adUnitConfig];
    };
}

@end
