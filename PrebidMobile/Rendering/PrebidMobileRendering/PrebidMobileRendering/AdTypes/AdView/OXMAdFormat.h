//
//  PBMAdFormat.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PrebidMobileRendering/PBMAdFormat.h>

#pragma mark - PBMAdFormatInternal

/**
 Determines the type of an AdIndentifier Object

 - OXMAdFormatDisplay: use  Ad Unit ID
 - OXMAdFormatVideo: use vastURL
 */
typedef NS_ENUM(NSInteger, OXMAdFormat) {
    OXMAdFormatDisplay = PBMAdFormatDisplay,
    OXMAdFormatVideo = PBMAdFormatVideo,
    OXMAdFormatNative,
    //PBMAdFormatMultiformat,
};
