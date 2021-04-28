//
//  PBMAppInfoParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMConstants.h"
#import "PBMLog.h"
#import "PBMMacros.h"
#import "PBMORTB.h"
#import "PBMORTBBidRequest.h"
#import "PBMSDKConfiguration.h"

#import "PBMAppInfoParameterBuilder.h"

#pragma mark - Internal Extension

@interface PBMAppInfoParameterBuilder ()

@property (nonatomic, strong, readonly) id<PBMBundleProtocol> bundle;
@property (nonatomic, strong, readonly) PBMTargeting *targeting;

@end

#pragma mark - Implementation

@implementation PBMAppInfoParameterBuilder

#pragma mark - Properties

//Keys into Bundle info Dict
+ (NSString *)bundleNameKey {
    return @"CFBundleName";
}

+ (NSString *)bundleDisplayNameKey {
    return @"CFBundleDisplayName";
}

#pragma mark - Initialization

- (nonnull instancetype)initWithBundle:(id<PBMBundleProtocol>)bundle targeting:(PBMTargeting *)targeting {
    if (!(self = [super init])) {
        return nil;
    }
    PBMAssert(bundle && targeting);
    _bundle = bundle;
    _targeting = targeting;
    
    return self;
}

#pragma mark - PBMParameterBuilder

- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest {
    if (!(self.bundle && bidRequest)) {
        PBMLogError(@"Invalid properties");
        return;
    }
    
    NSString *bundleIdentifier = self.bundle.bundleIdentifier;
    if (bundleIdentifier) {
        bidRequest.app.bundle = bundleIdentifier;
    }

    NSDictionary *bundleDict = self.bundle.infoDictionary;
    if (bundleDict) {
        NSString *bundleDisplayName = bundleDict[PBMAppInfoParameterBuilder.bundleDisplayNameKey];
        NSString *bundleName = bundleDict[PBMAppInfoParameterBuilder.bundleNameKey];
        NSString *appName = bundleDisplayName ? bundleDisplayName : bundleName;
        if (appName) {
            bidRequest.app.name = appName;
        }
    }
    
    NSString *publisherName = self.targeting.publisherName;
    if (!bidRequest.app.publisher.name && publisherName) {
        if (!bidRequest.app.publisher) {
            bidRequest.app.publisher = [PBMORTBPublisher new];
        }
        bidRequest.app.publisher.name = publisherName;
    }
}

@end