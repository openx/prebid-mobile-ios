//
//  PBMVastAdsBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastAdsBuilder.h"

#import "OXMError.h"
#import "PBMError.h"
#import "PBMLog.h"
#import "PBMAdDetails.h"
#import "PBMConstants.h"
#import "PBMVastParser.h"
#import "PBMVastInlineAd.h"
#import "PBMVastResponse.h"
#import "PBMVastRequester.h"
#import "PBMVastWrapperAd.h"
#import "PBMURLComponents.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMServerResponse.h"
#import "NSException+PBMExtensions.h"
#import "PBMVastCreativeLinear.h"
#import "PBMMacros.h"

typedef void(^PBMVastAdsBuilderWrapperCompletionBlock)(NSError *);

#pragma mark - Private Extension

@interface PBMVastAdsBuilder()

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) id<PBMServerConnectionProtocol> serverConnection;
@property (nonatomic, assign) NSInteger requestsPending;
@property (nonatomic, assign) NSInteger maximumWrapperDepth;     // Per VAST 4.0 spec section 2.3.4.1
@property (nonatomic, strong, nullable) PBMVastResponse *rootResponse;

@end

#pragma mark - Implementation

@implementation PBMVastAdsBuilder

#pragma mark - Initialization

-(instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)serverConnection {
    self = [super init];
    if (self) {
        PBMAssert(serverConnection);
        
        self.requestsPending = 0;
        self.maximumWrapperDepth = 5;
        self.serverConnection = serverConnection;
        self.dispatchQueue = dispatch_queue_create("PBMVastLoaderQueue", NULL);
    }
    return self;
}

#pragma mark - Public

- (void)buildAds:(nonnull NSData *)data completion:(PBMVastAdsBuilderCompletionBlock)completionBlock {
    @weakify(self);
    [self buildAds:data wrapperAd:nil completion:^(NSError *error){
        @strongify(self);
        
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        NSArray<PBMVastAbstractAd *> *ads = [self extractAdsWithError:&error];
        completionBlock(ads, error);
    }];
}

- (BOOL)checkHasNoAdsAndFireURIs:(PBMVastResponse *)vastResponse {
    
    BOOL firedNoAdsURI = false;
    
    // To check no ads responses, we find any response that had an Ad/Inline element that had zero creatives.
    // Then we walk backward from that response to any preceding wrapper responses that have an errorURI provided.
    
    if (vastResponse.vastAbstractAds.count == 0) {
        
        //If we have no ads, fire noAdsResponseURI on every wrapper up the chain.
        //First check response itself. then loop up
        
        PBMVastResponse *parent = vastResponse;
        while (parent) {
            
            if (parent.noAdsResponseURI) {
                [self.serverConnection fireAndForget: parent.noAdsResponseURI];
            }
            
            //Avoid infinite loop
            if (parent.parentResponse == parent) {
                break;
            }
            
            parent = parent.parentResponse;
        }
        firedNoAdsURI = true;
    }
    else {
        
        for (PBMVastAbstractAd *ad in vastResponse.vastAbstractAds) {
            
            //If the Ad is a wrapper
            if ([ad isKindOfClass: [PBMVastWrapperAd class]]) {
                PBMVastWrapperAd *unwrappedVASTWrapper = (PBMVastWrapperAd *)ad;
                
                //And it has a response
                if (unwrappedVASTWrapper.vastResponse) {
                    PBMVastResponse *unwrappedVastResponse = unwrappedVASTWrapper.vastResponse;
                    firedNoAdsURI = firedNoAdsURI || [self checkHasNoAdsAndFireURIs:unwrappedVastResponse];
                }
                else {
                    PBMLogError(@"No vastResponse on Wrapper");
                }
            }
        }
    }
    
    return firedNoAdsURI;
}

#pragma mark - Private

- (void)buildAds:(nonnull NSData *)data wrapperAd:(PBMVastWrapperAd *)wrapperAd completion:(PBMVastAdsBuilderWrapperCompletionBlock)completionBlock {
    
    if (wrapperAd && (wrapperAd.depth > self.maximumWrapperDepth)) {
        NSError *error = [OXMError errorWithDescription:@"Wrapper limit reached, as defined by the video player. Too many Wrapper responses have been received with no InLine response." statusCode:PBMErrorCodeUndefined];
        completionBlock(error);
        return;
    }
    
    PBMVastParser *parser = [PBMVastParser new];
    PBMVastResponse *parsedResponse = [parser parseAdsResponse:data];
    if (!parsedResponse) {
        NSString *strVast = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *message = [NSString stringWithFormat:@"VAST Parsing failed. XML was:  %@", strVast];
        completionBlock([OXMError errorWithDescription:message statusCode:PBMErrorCodeUndefined]);
        return;
    }

    @weakify(self);
    [self handleResponse:parsedResponse forWrapperAd:wrapperAd completion:^(NSError *error) {
        @strongify(self);
        if (!self) {
            completionBlock([OXMError errorWithDescription:@"VAST error: the ads builder is failed" statusCode:PBMErrorCodeUndefined]);
            return;
        }
        
        if (error) {
            completionBlock(error);
            return;
        }
        
        if (wrapperAd) {
            dispatch_sync(self.dispatchQueue, ^{
                self.requestsPending -= 1;
            });

            completionBlock(nil);
        } else if (self.requestsPending == 0) {
            completionBlock(nil);
        }
    }];
}

- (void)requestAds:(NSString *)vastURL
      forWrapperAd:(PBMVastWrapperAd *)wrapperAd
        completion:(PBMVastAdsBuilderWrapperCompletionBlock)completion {
    
    @weakify(self);
    dispatch_sync(self.dispatchQueue, ^{
        @strongify(self);
        if (!self) {
            completion([OXMError errorWithDescription:@"VAST error: the ads builder is failed" statusCode:PBMErrorCodeUndefined]);
            return;
        }
        
        self.requestsPending += 1;
    });
    
    [self.serverConnection get:vastURL timeout:PBMTimeInterval.CONNECTION_TIMEOUT_DEFAULT callback:^(PBMServerResponse * _Nonnull serverResponse) {
        if (serverResponse.error) {
            completion(serverResponse.error);
            return;
        }
        
        if (serverResponse.statusCode != 200) {
            NSString *message = [NSString stringWithFormat:@"Server responded with status code %li", (long)serverResponse.statusCode];
            completion([OXMError errorWithDescription:message statusCode:serverResponse.statusCode]);
            return;
        }
        
        [self buildAds:serverResponse.rawData wrapperAd:wrapperAd completion:completion];
    }];
}

- (void)handleResponse:(PBMVastResponse *)response
          forWrapperAd:(PBMVastWrapperAd *)wrapperAd
            completion:(PBMVastAdsBuilderWrapperCompletionBlock)completionBlock {
    
    if (wrapperAd) {
        //Assign nextResponse and parentResponse
        wrapperAd.vastResponse = response;
        response.parentResponse = wrapperAd.ownerResponse;
        
        //If multiple ads are disabled, drop everything but the first ad with a sequence of 0.
        if (!wrapperAd.allowMultipleAds) {
            for (PBMVastAbstractAd *ad in response.vastAbstractAds) {
                if (ad.sequence == 0) {
                    response.vastAbstractAds = [NSMutableArray arrayWithObject:ad];
                    break;
                }
            }
        }
        
        //If the parent asked us not to follow wrappers, remove any wrappers we find in the response.
        if (!wrapperAd.followAdditionalWrappers) {
            NSMutableArray *filtered = [NSMutableArray array];
            for (id obj in response.vastAbstractAds) {
                if (![obj isKindOfClass:[PBMVastWrapperAd class]]) {
                    [filtered addObject:obj];
                }
            }
            response.vastAbstractAds = filtered;
        }
        
        //Copy parent's allowMultipleAds setting to child wrappers
        for (id obj in response.vastAbstractAds) {
            if ([obj isKindOfClass:[PBMVastWrapperAd class]]) {
                PBMVastWrapperAd *wrapper = obj;
                wrapper.allowMultipleAds = wrapperAd.allowMultipleAds;
            }
        }
    }
    else {
        // If parentWrapper is nil, this is the root response.
        self.rootResponse = response;
    }
    
    //If we're not at the max depth then add a request for each wrapper.
    BOOL hasWrappers = NO;
    for (id obj in response.vastAbstractAds) {
        if ([obj isKindOfClass:[PBMVastWrapperAd class]]) {
            hasWrappers = YES;

            PBMVastWrapperAd *responseWrapperAd = obj;
            responseWrapperAd.depth = wrapperAd.depth + 1;
            
            [self requestAds:responseWrapperAd.vastURI forWrapperAd:responseWrapperAd completion:completionBlock];
        }
    }
    
    if (!hasWrappers) {
        completionBlock(nil);
    }
}

-(BOOL)hasValidMedia:(NSArray *)ads {
    for (PBMVastInlineAd *ad in ads) {
        for (PBMVastCreativeAbstract *creative in ad.creatives) {
            if ([creative isKindOfClass:[PBMVastCreativeLinear class]]) {
                PBMVastCreativeLinear *pbmVastCreativeLinear = (PBMVastCreativeLinear*) creative;
                if ([pbmVastCreativeLinear bestMediaFile]) {
                    return true;
                }
            }
        }
    }
    return false;
}

- (NSArray<PBMVastAbstractAd *> *)extractAdsWithError:(NSError *__autoreleasing  _Nullable *)error {
    if (!self.rootResponse) {
        [OXMError createError:error description:@"No Root Response" statusCode:PBMErrorCodeFileNotFound];
        return nil;
    }
    
    // check for ads & media and fire appropriate URIs
    if ([self checkHasNoAdsAndFireURIs: self.rootResponse]) {
        [OXMError createError:error description:@"One or more responses had no ads" statusCode:PBMErrorCodeGeneralLinear];
        return nil;
    }
    
    NSError *flatterError;
    NSArray *ads = [self.rootResponse flattenResponseAndReturnError:&flatterError];
    if (flatterError) {
        if(error != nil) {
            *error = [flatterError copy];
        }
        return nil;
    }
    
    if (![self hasValidMedia:ads]) {
        [OXMError createError:error description:@"No Valid Media" statusCode:PBMErrorCodeFileNotFound];
        return nil;
    }
    
    return ads;
}

@end
