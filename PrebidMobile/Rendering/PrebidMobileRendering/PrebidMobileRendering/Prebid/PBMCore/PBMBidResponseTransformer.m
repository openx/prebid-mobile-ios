//
//  PBMBidResponseTransformer.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidResponseTransformer.h"
#import "PBMError.h"
#import "PBMServerResponse.h"
#import "PBMORTBAbstract+Protected.h"

// Fix Build
#import "PBMPlayable.h"
#import "PBMAdViewManagerDelegate.h"
#import "PBMConstants.h"
#import "PBMDataAssetType.h"
#import "PBMJsonCodable.h"

#import "PBMNativeEventType.h"
#import "PBMNativeEventTrackingMethod.h"

#import "PBMNativeContextType.h"
#import "PBMNativeContextSubtype.h"
#import "PBMNativePlacementType.h"
#import "PBMBaseAdUnit.h"
#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"

#import "PBMImageAssetType.h"
#import "PBMNativeAdElementType.h"

#import "PBMAdLoadFlowControllerDelegate.h"
#import "PBMBannerAdLoaderDelegate.h"
#import "PBMBannerEventInteractionDelegate.h"
#import "PBMDisplayViewInteractionDelegate.h"

#import "PBMBaseInterstitialAdUnit.h"
#import "PBMRewardedEventInteractionDelegate.h"
#import "PBMAdPosition.h"
#import "PBMVideoPlacementType.h"
#import "PBMAdFormat.h"

#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@implementation PBMBidResponseTransformer

+ (PBMBidResponse *)transformResponse:(PBMServerResponse *)response error:(NSError **)error {
    NSString * const responseBody = [[NSString alloc] initWithData:response.rawData encoding:NSUTF8StringEncoding];
    if ([responseBody containsString:@"Invalid request"]) {
        if (error) {
            *error = [self classifyRequestError:responseBody];
        }
        return nil;
    }
    if (!response.jsonDict) {
        if (error) {
            *error = [PBMError jsonDictNotFound];
        }
        return nil;
    }
    PBMBidResponse * const bidResponse = [[PBMBidResponse alloc] initWithJsonDictionary:response.jsonDict];
    if (!bidResponse) {
        if (error) {
            *error = [PBMError responseDeserializationFailed];
        }
        return nil;
    }
    if (error) {
        *error = nil;
    }
    return bidResponse;
}

+ (NSError *)classifyRequestError:(NSString *)responseBody {
    if ([responseBody containsString:@"Stored Imp with ID"] || [responseBody containsString:@"No stored imp found"]) {
        return [PBMError invalidConfigId];
    }
    if ([responseBody containsString:@"Stored Request with ID"] || [responseBody containsString:@"No stored request found"]) {
        return [PBMError invalidAccountId];
    }
    if ([responseBody containsString:@"Invalid request: Request imp[0].banner.format"] || [responseBody containsString:@"Request imp[0].banner.format"] || [responseBody containsString:@"Unable to set interstitial size list"]) {
        return [PBMError invalidSize];
    }
    return [PBMError serverError:responseBody];
}

@end
