//
//  PBMNativeMarkupRequestObject.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "PBMPlayable.h"
#import "PBMAdViewManagerDelegate.h"
#import "PBMConstants.h"
#import "PBMJsonCodable.h"

#import "PBMNativeEventTrackingMethod.h"

#import "PBMNativeContextType.h"
#import "PBMNativeContextSubtype.h"
#import "PBMNativePlacementType.h"
#import "PBMBaseAdUnit.h"
#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

#import "PBMNativeMarkupRequestObject.h"
#import "PBMNativeMarkupRequestObject+Internal.h"

#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"

#import "NSNumber+PBMORTBNative.h"
#import "NSDictionary+PBMORTBNativeExt.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@interface PBMNativeMarkupRequestObject ()
@property (nonatomic, strong) NSArray<NativeAsset *> *rawAssets;
@property (nonatomic, strong, nullable) NSString *rawVersion;
@property (nonatomic, strong, nullable) NSArray<NativeEventTracker *> *rawEventTrackers;
@end


@implementation PBMNativeMarkupRequestObject

- (instancetype)initWithAssets:(NSArray<NativeAsset *> *)assets {
    if(!(self = [super init])) {
        return nil;
    }
    _assets = [assets copy];
    _version = @"1.2";
    return self;
}

// MARK: - Raw Property Accessors

- (NSArray<NativeAsset *> *)rawAssets {
    return _assets;
}

- (void)setRawAssets:(NSArray<NativeAsset *> *)rawAssets {
    _assets = rawAssets;
}

- (void)setExt:(nullable NSDictionary<NSString *, id> *)ext {
    _ext = ext;
}

- (void)setRawVersion:(NSString *)rawVersion {
    _version = rawVersion;
}

- (NSString *)rawVersion {
    return _version;
}

- (void)setRawEventTrackers:(NSArray<NativeEventTracker *> *)rawEventTrackers {
    _eventtrackers = rawEventTrackers;
}

- (NSArray<NativeEventTracker *> *)rawEventTrackers {
    return _eventtrackers;
}

// MARK: - PBMJsonCodable

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    return [PBMFunctions toStringJsonDictionary:self.jsonDictionary error:error];
}

- (nullable PBMJsonDictionary *)jsonDictionary {
    PBMMutableJsonDictionary * const json = [[PBMMutableJsonDictionary alloc] init];
    json[@"ver"] = self.version;
    json[@"context"] = self.context.integerNumber;
    json[@"contextsubtype"] = self.contextsubtype.integerNumber;
    json[@"plcmttype"] = self.plcmttype.integerNumber;
    json[@"seq"] = self.seq.integerNumber;
    json[@"assets"] = self.jsonAssets;
    json[@"plcmtcnt"] = self.plcmtcnt.integerNumber;
    json[@"aurlsupport"] = self.aurlsupport.integerNumber;
    json[@"durlsupport"] = self.durlsupport.integerNumber;
    json[@"eventtrackers"] = self.jsonTrackers;
    json[@"privacy"] = self.privacy.integerNumber;
    json[@"ext"] = self.ext;
    return json;
}

- (NSArray<PBMJsonDictionary *> *)jsonAssets {
    NSMutableArray<PBMJsonDictionary *> * const serializedAssets = [[NSMutableArray alloc] initWithCapacity:self.assets.count];
    for(NativeAsset *nextAsset in self.assets) {
        [serializedAssets addObject:nextAsset.jsonDictionary];
    }
    return serializedAssets;
}

- (nullable NSArray<PBMJsonDictionary *> *)jsonTrackers {
    if (!self.eventtrackers) {
        return nil;
    }
    NSMutableArray<PBMJsonDictionary *> * const serializedTrackers = [[NSMutableArray alloc] initWithCapacity:self.eventtrackers.count];
    for(NativeEventTracker *nextTracker in self.eventtrackers) {
        [serializedTrackers addObject:nextTracker.jsonDictionary];
    }
    return serializedTrackers;
}

// MARK: - Ext

- (BOOL)setExt:(nullable NSDictionary<NSString *, id> *)ext
         error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSError *localError = nil;
    PBMJsonDictionary * const newExt = [ext unserializedCopyWithError:&localError];
    if (error) {
        *error = localError;
    }
    if (localError) {
        return NO;
    }
    _ext = newExt;
    return YES;
}

// MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    PBMNativeMarkupRequestObject * const clone = [[[self class] alloc] initWithAssets:@[]];
    clone.rawVersion = self.rawVersion;
    clone.context = self.context;
    clone.contextsubtype = self.contextsubtype;
    clone.plcmttype = self.plcmttype;
    clone.plcmtcnt = self.plcmtcnt;
    clone.seq = self.seq;
    clone.rawAssets = self.rawAssets;
    clone.aurlsupport = self.aurlsupport;
    clone.durlsupport = self.durlsupport;
    clone.rawEventTrackers = self.rawEventTrackers;
    clone.privacy = self.privacy;
    clone.ext = self.ext;
    return clone;
}

@end

