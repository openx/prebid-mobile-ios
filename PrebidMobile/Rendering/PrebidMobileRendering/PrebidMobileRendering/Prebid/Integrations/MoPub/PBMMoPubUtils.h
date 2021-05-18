//
//  PBMMoPubUtils.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const PBMMoPubAdUnitBidKey;
FOUNDATION_EXPORT NSString * const PBMMoPubConfigIdKey;
FOUNDATION_EXPORT NSString * const PBMMoPubAdNativeResponseKey;

@class PBMNativeAd;

typedef void(^PBMFindNativeAdHandler)(PBMNativeAd * _Nullable, NSError * _Nullable);

/**
 A protocol for ad objects supported by Prebid MoPub adunits
 (MPAdView, MPInterstitialAdController, MPNativeAdRequestTargeting)
 */
@protocol PBMMoPubAdObjectProtocol <NSObject>
@required
@property (nonatomic, nullable, copy) NSString *keywords;
@property (nonatomic, nullable, copy) NSDictionary *localExtras;
@end

@interface PBMMoPubUtils : NSObject

/**
 Checks that a passed object confirms to the PBMMoPubAdObjectProtocol
 @return YES if the passed object is correct, FALSE otherwise
 */
+ (BOOL)isCorrectAdObject:(NSObject *)adObject;

/**
 Finds an native ad object in the given extra dictionary.
 Calls the provided callback whith the finded native ad object or error
 */
+ (void)findNativeAd:(NSDictionary *_Nullable)extras callback:(nonnull PBMFindNativeAdHandler)completion;


/**
 Removes an bid info from ad object's localExtra
 and prebid-specific keywords from ad object's keywords
 */
+ (void)cleanUpAdObject:(id<PBMMoPubAdObjectProtocol>)adObject;

/**
 Puts to ad object's localExtra the ad object (winning bid or native ad) and configId
 and populates adObject's keywords by targeting info
 @return YES on success and NO otherwise (when the passed ad has wrong type)
 */
+ (BOOL)setUpAdObject:adObject
         withConfigId:(NSString *)configId
        targetingInfo:(NSDictionary<NSString *,NSString *> *)targetingInfo
          extraObject:(id)anObject forKey:(NSString *)aKey;


@end

NS_ASSUME_NONNULL_END


