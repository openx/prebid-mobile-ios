//
//  OXASDKConfiguration+oxmTestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@interface PrebidRenderingConfig (Private)

//If true, forces viewabilityManager to return positive value.
@property (nonatomic, assign) BOOL forcedIsViewable;

//Assigns a newly initialized instance to the (class property) backing variable
+ (void)resetSingleton;

@end
