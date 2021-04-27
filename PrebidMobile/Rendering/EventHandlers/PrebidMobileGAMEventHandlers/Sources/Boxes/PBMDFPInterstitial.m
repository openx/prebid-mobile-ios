//
//  PBMDFPInterstitial.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMDFPInterstitial.h"
#import "PBMInvocationHelper.h"


static NSNumber *classesCheckResult = nil;

@interface PBMDFPInterstitial ()

@property (nonatomic, strong, readonly) GAMInterstitialAd *interstitial;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

@implementation PBMDFPInterstitial

// MARK: - Lifecycle

- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
    if (!(self = [super init])) {
        return nil;
    }
    
    // _interstitial = [[DFPInterstitial alloc] initWithAdUnitID:adUnitID];
    
    return self;
}

// MARK: - Public (own) properties

+ (BOOL)classesFound {
    if (classesCheckResult != nil) {
        return classesCheckResult.boolValue;
    }
    const BOOL classesFound = [self findClasses];
    classesCheckResult = @(classesFound);
    return classesFound;
}

- (NSObject *)boxedInterstitial {
    return self.interstitial;
}

// MARK: - Public (Boxed) Properties

- (BOOL)isReady {
    BOOL result = NO;
    __block NSValue *resultValue = nil;
    [PBMInvocationHelper invokeCResultSelector:@selector(isReady)
                                      onTarget:self.interstitial
                                    resultType:@encode(BOOL)
                                      onResult:^(NSValue * _Nullable resultObj) {
        resultValue = resultObj;
    }
                                   onException:nil];
    [resultValue getValue:&result];
    return result;
}

- (void)setDelegate:(id<GADFullScreenContentDelegate>)delegate {
    [PBMInvocationHelper invokeVoidSelector:@selector(setDelegate:)
                                 withObject:delegate
                                   onTarget:self.interstitial
                                onException:nil];
}

- (id<GADFullScreenContentDelegate>)delegate {
    __block id<GADFullScreenContentDelegate> result = nil;
    [PBMInvocationHelper invokeProtocolResultSelector:@selector(delegate)
                                             onTarget:self.interstitial
                                       resultProtocol:@protocol(GADFullScreenContentDelegate)
                                            outResult:&result
                                          onException:nil];
    return result;
}

- (void)setAppEventDelegate:(id<GADAppEventDelegate>)appEventDelegate {
    [PBMInvocationHelper invokeVoidSelector:@selector(setAppEventDelegate:)
                                 withObject:appEventDelegate
                                   onTarget:self.interstitial
                                onException:nil];
}

- (id<GADAppEventDelegate>)appEventDelegate {
    __block id<GADAppEventDelegate> result = nil;
    [PBMInvocationHelper invokeProtocolResultSelector:@selector(appEventDelegate)
                                             onTarget:self.interstitial
                                       resultProtocol:@protocol(GADAppEventDelegate)
                                            outResult:&result
                                          onException:nil];
    return result;
}

// MARK: - Public methods

- (void)loadRequest:(PBMGAMRequest *)request {
    [PBMInvocationHelper invokeVoidSelector:@selector(loadRequest:)
                                 withObject:request.boxedRequest
                                   onTarget:self.interstitial
                                onException:nil];
}

- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController {
    [PBMInvocationHelper invokeVoidSelector:@selector(presentFromRootViewController:)
                                 withObject:rootViewController
                                   onTarget:self.interstitial
                                onException:nil];
}

// MARK: - Private Helpers

+ (BOOL)findClasses {
    BOOL result = NO;
    @try {
        if (!NSClassFromString(@"GAMInterstitialAd")) {
            return NO;
        }
        if (!NSProtocolFromString(@"GADFullScreenContentDelegate")) {
            return NO;
        }
        if (!NSProtocolFromString(@"GADAppEventDelegate")) {
            return NO;
        }
        
        // Check static method
        [GADInterstitialAd loadWithAdUnitID:@""
                                    request:nil
                          completionHandler:nil];
        
        Class const testClass = [GADInterstitialAd class];
        SEL selectors[] = {
            @selector(fullScreenContentDelegate),
            @selector(setFullScreenContentDelegate:),
            @selector(appEventDelegate),
            @selector(setAppEventDelegate:),
            @selector(presentFromRootViewController:),
        };
        const size_t selectorsCount = sizeof(selectors) / sizeof(selectors[0]);
        for(size_t i = 0; i < selectorsCount; i++) {
            if (![testClass instancesRespondToSelector:selectors[i]]) {
                return NO;
            }
        }
        result = YES;
    }
    @catch(id anException) {
        result = NO;
    };
    return result;
}

@end
