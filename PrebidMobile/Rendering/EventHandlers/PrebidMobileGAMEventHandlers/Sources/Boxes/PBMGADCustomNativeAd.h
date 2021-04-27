//
//  PBMGADNativeCustomTemplateAd.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class GADCustomNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface PBMGADCustomNativeAd : NSObject

@property (nonatomic, class, readonly) BOOL classesFound;
@property (nonatomic, strong, readonly) NSObject *boxedAd;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCustomNativeAd:(GADCustomNativeAd *)customNativeAd NS_DESIGNATED_INITIALIZER;

/// Returns the string corresponding to the specified key or nil if the string is not available.
- (nullable NSString *)stringForKey:(nonnull NSString *)key;

@end

NS_ASSUME_NONNULL_END