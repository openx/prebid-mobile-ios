//
//  PBMBasicParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMAdConfiguration.h"
#import "PBMParameterBuilderProtocol.h"

@class PrebidRenderingConfig;
@class PrebidRenderingTargeting;

NS_ASSUME_NONNULL_BEGIN
@interface PBMBasicParameterBuilder : NSObject <PBMParameterBuilder>

@property (class, readonly) NSString *platformKey;
@property (class, readonly) NSString *platformValue;
@property (class, readonly) NSString *allowRedirectsKey;
@property (class, readonly) NSString *allowRedirectsVal;
@property (class, readonly) NSString *sdkVersionKey;
@property (class, readonly) NSString *urlKey;
@property (class, readonly) NSString *rewardedVideoKey;
@property (class, readonly) NSString *rewardedVideoValue;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdConfiguration:(PBMAdConfiguration *)adConfiguration
                       sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                             sdkVersion:(NSString *)sdkVersion
                              targeting:(PrebidRenderingTargeting *)targeting NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
