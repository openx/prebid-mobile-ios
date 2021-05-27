//
//  BasicParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMTargeting+Private.h"
#import "PBMConstants.h"
#import "PBMMacros.h"
#import "PBMORTB.h"

#import "PBMBasicParameterBuilder.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

#pragma mark - Internal Extension

@interface PBMBasicParameterBuilder ()

// Note: properties below are marked with 'readwrite' for UnitTests to be able to write 'nil' into them.
// TODO: Prove that 'init' arguments are never nil; convert to 'readonly'; remove redundant checks and tests.

@property (nonatomic, strong, readwrite) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong, readwrite) PrebidRenderingConfig *sdkConfiguration;
@property (nonatomic, strong, readwrite) PBMTargeting *targeting;
@property (nonatomic, copy, readwrite) NSString *sdkVersion;

@end

#pragma mark - Implementation

@implementation PBMBasicParameterBuilder

#pragma mark - Properties

+ (NSString *)platformKey {
    return @"sp";
}

+ (NSString *)platformValue {
    return @"iOS";
}

+ (NSString *)allowRedirectsKey {
    return @"dr";
}

+ (NSString *)allowRedirectsVal {
    return @"true";
}

+ (NSString *)sdkVersionKey {
    return @"sv";
}

+ (NSString *)urlKey {
    return PBMParameterKeysAPP_STORE_URL;
}

+ (NSString*)rewardedVideoKey {
    return @"vrw";
}

+ (NSString*)rewardedVideoValue {
    return @"1";
}

#pragma mark - Initialization

- (instancetype)initWithAdConfiguration:(PBMAdConfiguration *)adConfiguration
                       sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                             sdkVersion:(NSString *)sdkVersion
                              targeting:(PBMTargeting *)targeting
{
    if (!(self = [super init])) {
        return nil;
    }
    PBMAssert(adConfiguration && sdkConfiguration && sdkVersion && targeting);
    
    _adConfiguration = adConfiguration;
    _sdkConfiguration = sdkConfiguration;
    _sdkVersion = sdkVersion;
    _targeting = targeting;
    
    return self;
}

#pragma mark - Methods

- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest {
    if (!(self.adConfiguration && self.sdkConfiguration && self.sdkVersion)) {
        PBMLogError(@"Invalid properties");
        return;
    }

    //Add an impression if none exist
    if ([bidRequest.imp count] == 0) {
        bidRequest.imp = @[[[PBMORTBImp alloc] init]];
    }
    
    for (PBMORTBImp *rtbImp in bidRequest.imp) {
        rtbImp.displaymanagerver = self.sdkVersion;
        rtbImp.instl = @(self.adConfiguration.presentAsInterstitial ? 1 : 0);
        
        //set secure=1 for https or secure=0 for http
        rtbImp.secure = @1;
        
        rtbImp.clickbrowser = @(self.sdkConfiguration.useExternalClickthroughBrowser ? 1 : 0);
    }
    
    bidRequest.regs.coppa = self.targeting.coppa;
    
    [self appendFormatSpecificParametersForRequest:bidRequest];
}

- (void)appendFormatSpecificParametersForRequest:(PBMORTBBidRequest *)bidRequest {
    switch (self.adConfiguration.adFormat) {
        case PBMAdFormatDisplayInternal:
            [self appendDisplayParametersForRequest:bidRequest];
            break;
            
        case PBMAdFormatVideoInternal:
            [self appendVideoParametersForRequest:bidRequest];
            break;
            
        case PBMAdFormatNativeInternal: {
            [self appendNativeParametersForRequest:bidRequest];
            break;
        }
    }
}

- (void)appendDisplayParametersForRequest:(PBMORTBBidRequest *)bidRequest {
    //Ensure there's at least 1 banner
    BOOL hasBanner = NO;
    for (PBMORTBImp *imp in bidRequest.imp) {
        if (imp.banner) {
            hasBanner = YES;
            break;
        }
    }
    
    if (!hasBanner) {
        [bidRequest.imp firstObject].banner = [[PBMORTBBanner alloc] init];
    }
}

- (void)appendVideoParametersForRequest:(PBMORTBBidRequest *)bidRequest {

    PBMORTBVideo * const videoObj = [[PBMORTBVideo alloc] init];
    
    if (self.adConfiguration.videoPlacementType != PBMVideoPlacementType_Undefined) {
        videoObj.placement = @(self.adConfiguration.videoPlacementType);
    }
    [bidRequest.imp firstObject].video = videoObj;
}

- (void)appendNativeParametersForRequest:(PBMORTBBidRequest *)bidRequest {
    [bidRequest.imp firstObject].native = [[PBMORTBNative alloc] init];
}

@end
