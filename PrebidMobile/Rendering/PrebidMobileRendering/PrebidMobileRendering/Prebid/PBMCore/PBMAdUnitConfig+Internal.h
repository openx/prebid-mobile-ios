//
//  PBMAdUnitConfig+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMAdUnitConfig.h"

#import "PBMAdConfiguration.h"
#import "OXMAdFormat.h"

@interface PBMAdUnitConfig ()

@property (nonatomic, strong, nonnull, readonly) PBMAdConfiguration *adConfiguration;
@property (atomic, strong, nonnull, readonly) NSDictionary<NSString *, NSArray<NSString *> *> *contextDataDictionary;

@end
