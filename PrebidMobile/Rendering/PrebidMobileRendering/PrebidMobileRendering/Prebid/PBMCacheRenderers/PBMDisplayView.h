//
//  PBMDisplayView.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBMDisplayViewLoadingDelegate.h"

@class Bid;
@protocol DisplayViewInteractionDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface PBMDisplayView : UIView

@property (atomic, weak, nullable) id<PBMDisplayViewLoadingDelegate> loadingDelegate;
@property (atomic, weak, nullable) NSObject<DisplayViewInteractionDelegate> *interactionDelegate;
@property (nonatomic, readonly) BOOL isCreativeOpened;

- (instancetype)initWithFrame:(CGRect)frame bid:(Bid *)bid configId:(NSString *)configId;

- (void)displayAd;

@end

NS_ASSUME_NONNULL_END
