//
//  PBMPrebidParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMPrebidParameterBuilder.h"

#import "PBMORTB.h"
#import "PBMUserAgentService.h"

#import "PBMAdViewManagerDelegate.h"
#import "PBMPlayable.h"
#import "PBMJsonCodable.h"
#import "PBMNativeContextType.h"
#import "PBMNativeContextSubtype.h"
#import "PBMNativePlacementType.h"

#import "PBMBaseAdUnit.h"
#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@interface PBMPrebidParameterBuilder ()

@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adConfiguration;
@property (nonatomic, strong, nonnull, readonly) PrebidRenderingConfig *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) PrebidRenderingTargeting *targeting;
@property (nonatomic, strong, nonnull, readonly) PBMUserAgentService *userAgentService;

@end

@implementation PBMPrebidParameterBuilder

- (instancetype)initWithAdConfiguration:(AdUnitConfig *)adConfiguration
                       sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                              targeting:(PrebidRenderingTargeting *)targeting
                       userAgentService:(PBMUserAgentService *)userAgentService
{
    if (!(self = [super init])) {
        return nil;
    }
    _adConfiguration = adConfiguration;
    _sdkConfiguration = sdkConfiguration;
    _targeting = targeting;
    _userAgentService = userAgentService;
    return self;
}

- (void)buildBidRequest:(nonnull PBMORTBBidRequest *)bidRequest {
    
    PBMAdFormatInternal const adFormat = self.adConfiguration.adConfiguration.adFormat;
    BOOL const isHTML = (adFormat == PBMAdFormatDisplayInternal);
    BOOL const isInterstitial = self.adConfiguration.isInterstitial;
    
    bidRequest.requestID = [NSUUID UUID].UUIDString;
    bidRequest.extPrebid.storedRequestID    = self.sdkConfiguration.accountID;
    bidRequest.extPrebid.dataBidders        = self.targeting.accessControlList;
    bidRequest.app.publisher.publisherID    = self.sdkConfiguration.accountID;
    
    bidRequest.app.ver          = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    bidRequest.device.pxratio   = @([UIScreen mainScreen].scale);
    bidRequest.source.tid       = [NSUUID UUID].UUIDString;
    bidRequest.device.ua        = [self.userAgentService getFullUserAgent];
    
    NSArray<PBMORTBFormat *> *formats = nil;
    const NSInteger formatsCount = (CGSizeEqualToSize(self.adConfiguration.adSize, CGSizeZero) ? 0 : 1) + self.adConfiguration.additionalSizes.count;
    
    if (formatsCount > 0) {
        NSMutableArray<PBMORTBFormat *> * const newFormats = [[NSMutableArray alloc] initWithCapacity:formatsCount];
        if (!CGSizeEqualToSize(self.adConfiguration.adSize, CGSizeZero)) {
            NSValue *value = [NSValue valueWithCGSize:self.adConfiguration.adSize];
            [newFormats addObject:[PBMPrebidParameterBuilder ortbFormatWithSize: value]];
        }
        for (NSValue *nextSize in self.adConfiguration.additionalSizes) {
            [newFormats addObject:[PBMPrebidParameterBuilder ortbFormatWithSize:nextSize]];
        }
        formats = newFormats;
    } else if (isInterstitial) {
        NSNumber * const w = bidRequest.device.w;
        NSNumber * const h = bidRequest.device.h;
        if (w && h) {
            PBMORTBFormat * const newFormat = [[PBMORTBFormat alloc] init];
            newFormat.w = w;
            newFormat.h = h;
            formats = @[newFormat];
        }
        if (self.adConfiguration.minSizePerc && isHTML) {
            const CGSize minSizePerc = self.adConfiguration.minSizePerc.CGSizeValue;
            PBMORTBDeviceExtPrebidInterstitial * const interstitial = bidRequest.device.extPrebid.interstitial;
            interstitial.minwidthperc = @(minSizePerc.width);
            interstitial.minheightperc = @(minSizePerc.height);
        }
    }
    
    PBMORTBAppExtPrebid * const appExtPrebid = bidRequest.app.extPrebid;
    
    appExtPrebid.data = self.targeting.contextDataDictionary;
    
    for (PBMORTBImp *nextImp in bidRequest.imp) {
        nextImp.impID = [NSUUID UUID].UUIDString;
        nextImp.extPrebid.storedRequestID = self.adConfiguration.configID;
        nextImp.extPrebid.isRewardedInventory = self.adConfiguration.isOptIn;
        nextImp.extContextData = self.adConfiguration.contextDataDictionary;
        switch (adFormat) {
            case PBMAdFormatDisplayInternal: {
                PBMORTBBanner * const nextBanner = nextImp.banner;
                if (formats) {
                    nextBanner.format = formats;
                }
                if (self.adConfiguration.adPosition != AdPositionUndefined) {
                    nextBanner.pos = @(self.adConfiguration.adPosition);
                }
                break;
            }
                
            case PBMAdFormatVideoInternal: {
                PBMORTBVideo * const nextVideo = nextImp.video;
                nextVideo.linearity = @(1); // -> linear/in-steam
                if (formats.count) {
                    PBMORTBFormat * const primarySize = (PBMORTBFormat *)formats[0];
                    nextVideo.w = primarySize.w;
                    nextVideo.h = primarySize.h;
                }
                if (self.adConfiguration.adPosition != AdPositionUndefined) {
                    nextVideo.pos = @(self.adConfiguration.adPosition);
                }
                break;
            }
                
            case PBMAdFormatNativeInternal: {
                PBMORTBNative * const nextNative = nextImp.native;
                nextNative.request = [self.adConfiguration.nativeAdConfiguration.markupRequestObject toJsonStringWithError:nil];
                NSString * const ver = self.adConfiguration.nativeAdConfiguration.version;
                if (ver) {
                    nextNative.ver = ver;
                }
                break;
            }
                
            default:
                break;
        }
        if (isInterstitial) {
            nextImp.instl = @(1);
        }
        if (!appExtPrebid.source) {
            appExtPrebid.source = nextImp.displaymanager;
        }
        if (!appExtPrebid.version) {
            appExtPrebid.version = nextImp.displaymanagerver;
        }
    }
    
    bidRequest.user.ext[@"data"] = self.targeting.userDataDictionary;
}

+ (PBMORTBFormat *)ortbFormatWithSize:(NSValue *)size {
    PBMORTBFormat * const format = [[PBMORTBFormat alloc] init];
    CGSize const cgSize = size.CGSizeValue;
    format.w = @(cgSize.width);
    format.h = @(cgSize.height);
    return format;
}

@end
