//
//  PBMError.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMError.h"
#import "PBMPublicConstants.h"
#import "PBMLog.h"

#pragma mark - Implementation

@implementation OXMError

+ (nonnull OXMError *)errorWithDescription:(nonnull NSString *)description {
    return [OXMError errorWithDescription:description statusCode:PBMErrorCodeGeneral];
}

+ (OXMError *)errorWithDescription:(NSString *)description statusCode:(PBMErrorCode)code {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil)
                               };
    
    return [OXMError errorWithDomain:PBMErrorDomain
                                code:code
                            userInfo:userInfo];
}

+ (OXMError *)errorWithMessage:(NSString *)message type:(PBMErrorType)type {
    NSString *desc = [NSString stringWithFormat:@"%@: %@", type, message];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:desc};
    return [OXMError errorWithDomain:PBMErrorDomain code:0 userInfo:userInfo];
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error description:(NSString *)description {
    if (error != NULL) {
        *error = [OXMError errorWithDescription:description];
        PBMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error description:(NSString *)description statusCode:(PBMErrorCode)code {
    if (error != NULL) {
        *error = [OXMError errorWithDescription:description statusCode:code];
        PBMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error message:(NSString *)message type:(PBMErrorType)type {
    if (error != NULL) {
        *error = [OXMError errorWithMessage:message type:type];
        PBMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}

- (instancetype)init:(nonnull NSString*)msg {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(msg, nil)
                               };
    
    self = [super initWithDomain:PBMErrorDomain code:PBMErrorCodeGeneral userInfo:userInfo];
    if (self) {
        self.message = msg;
    }

    return self;
}

@end
