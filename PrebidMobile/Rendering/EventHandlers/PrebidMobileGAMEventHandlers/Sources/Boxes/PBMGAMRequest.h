//
//  PBMGAMRequest.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GAMRequest;

NS_ASSUME_NONNULL_BEGIN

@interface PBMGAMRequest : NSObject

@property (nonatomic, class, readonly) BOOL classesFound;
@property (nonatomic, strong, readonly) NSObject *boxedRequest;

// Boxed properties
@property(nonatomic, copy, nullable) NSDictionary *customTargeting;

- (instancetype)init; // convenience
- (instancetype)initWithDFPRequest:(GAMRequest *)gamRequest NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
