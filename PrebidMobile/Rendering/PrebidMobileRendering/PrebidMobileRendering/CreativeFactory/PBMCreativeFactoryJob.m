//
//  PBMCreativeFactoryJob.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMCreativeFactoryJob.h"
#import "PBMCreativeModel.h"
#import "PBMHTMLCreative.h"
#import "PBMVideoCreative.h"
#import "PBMAbstractCreative.h"
#import "PBMAdConfiguration.h"
#import "PBMSDKConfiguration.h"
#import "PBMDownloadDataHelper.h"
#import "PBMTransaction.h"
#import "PBMMacros.h"
#import "PBMError.h"
#import "PBMError.h"

@interface PBMCreativeFactoryJob ()

@property (nonatomic, strong) PBMCreativeModel *creativeModel;
@property (nonatomic, copy) PBMCreativeFactoryJobFinishedCallback finishedCallback;
@property (nonatomic, strong) id<PBMServerConnectionProtocol> serverConnection;
@property (nonatomic, strong) PBMTransaction *transaction;

@end

@implementation PBMCreativeFactoryJob {
    dispatch_queue_t _dispatchQueue;
}

- (nonnull instancetype)initFromCreativeModel:(nonnull PBMCreativeModel *)creativeModel
                                  transaction:(PBMTransaction *)transaction
                             serverConnection:(nonnull id<PBMServerConnectionProtocol>)serverConnection
                              finishedCallback:(PBMCreativeFactoryJobFinishedCallback)finishedCallback {
    self = [super init];
    if (self) {
        self.creativeModel = creativeModel;
        self.serverConnection = serverConnection;
        self.state = PBMCreativeFactoryJobStateInitialized;
        self.finishedCallback = finishedCallback;
        self.transaction = transaction;
        NSString *uuid = [[NSUUID UUID] UUIDString];
        const char *queueName = [[NSString stringWithFormat:@"PBMCreativeFactoryJob_%@", uuid] UTF8String];
        _dispatchQueue = dispatch_queue_create(queueName, NULL);
    }
    
    return self;
}

- (void)successWithCreative:(PBMAbstractCreative *)creative {
    self.creative = creative;
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (self.state == PBMCreativeFactoryJobStateRunning) {
            self.state = PBMCreativeFactoryJobStateSuccess;
            if (self.finishedCallback) {
                self.finishedCallback(self, NULL);
            }
        }
    });
}

- (void)failWithError:(NSError *)error {
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (self.state == PBMCreativeFactoryJobStateRunning) {
            self.state = PBMCreativeFactoryJobStateError;
            if (self.finishedCallback) {
                self.finishedCallback(self, error);
            }
        }
    });
}

- (void)startJob {
    [self startJobWithTimeInterval:[self getTimeInterval]];
}

/*
 For internal use only
 */
- (void)startJobWithTimeInterval:(NSTimeInterval)timeInterval {
    PBMAssert(self.creativeModel);
    if (!self.creativeModel) {
        [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Undefined creative model" type:PBMErrorTypeInternalError]];
        return;
    }
    
    [self startJobTimerWithTimeInterval:timeInterval];
    
    @weakify(self);
    dispatch_async(_dispatchQueue, ^{
        @strongify(self);
        if (self.state != PBMCreativeFactoryJobStateInitialized) {
            [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Tried to start PBMCreativeFactory twice" type:PBMErrorTypeInternalError]];
            return;
        }
        
        self.state = PBMCreativeFactoryJobStateRunning;
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!(self.creativeModel && self.creativeModel.adConfiguration)) {
            [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Undefined creative model" type:PBMErrorTypeInternalError]];
            return;
        }
        
        PBMAdFormatInternal adType = self.creativeModel.adConfiguration.adFormat;
        if (adType == PBMAdFormatVideoInternal) {
            [self attemptVASTCreative];
        } else if (adType == PBMAdFormatDisplayInternal || adType == PBMAdFormatNativeInternal) {
            [self attemptAUIDCreative];
        }
    });
}

- (void)startJobTimerWithTimeInterval:(NSTimeInterval)timeInterval {
    @weakify(self);
    __block void (^timer)(void) = ^{
        double delayInSeconds = timeInterval;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void){
            @strongify(self);
            [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Failed to complete in specified time interval" type:PBMErrorTypeInternalError]];
        });
    };
    
    timer();
}

- (void)attemptAUIDCreative {
    if (!(self.creativeModel && self.creativeModel.adConfiguration)) {
        [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Undefined creative model" type:PBMErrorTypeInternalError]];
        return;
    }
    
    self.creative = [[PBMHTMLCreative alloc] initWithCreativeModel:self.creativeModel
                                                       transaction:self.transaction];
    
    if ([self.creative isKindOfClass:[PBMHTMLCreative class]]) {
        PBMHTMLCreative *creative = (PBMHTMLCreative *)self.creative;
        creative.downloadBlock = [self createLoader];
    }
    
    self.creative.creativeResolutionDelegate = self;
    [self.creative setupView];
}

- (void)attemptVASTCreative {
    if (!self.creativeModel) {
        [self failWithError:[PBMError errorWithMessage:@"PBMCreativeFactoryJob: Undefined creative model" type:PBMErrorTypeInternalError]];
        return;
    }
    
    NSString *strUrl = self.creativeModel.videoFileURL;
    if (!strUrl) {
        [self failWithError:[PBMError errorWithDescription:@"PBMCreativeFactoryJob: Could not initialize VideoCreative without videoFileURL"]];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:strUrl];
    if (!url) {
        [self failWithError:[PBMError errorWithDescription:[NSString stringWithFormat:@"Could not create URL from url string: %@", strUrl]]];
        return;
    }
    
    PBMDownloadDataHelper *downloader = [[PBMDownloadDataHelper alloc] initWithPBMServerConnection:self.serverConnection];
    [downloader downloadDataForURL:url maxSize:PBMVideoCreative.maxSizeForPreRenderContent completionClosure:^(NSData * _Nullable preloadedData, NSError * _Nullable error) {
        if (error) {
            [self failWithError:error];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeVideoCreative:preloadedData];
        });
    }];
}

- (void)initializeVideoCreative:(NSData *)data {
    self.creative = [[PBMVideoCreative alloc] initWithCreativeModel:self.creativeModel transaction:self.transaction videoData:data];
    self.creative.creativeResolutionDelegate = self;
    [self.creative setupView];
}

- (NSTimeInterval)getTimeInterval {
    PBMAdConfiguration *adConfig = self.creativeModel.adConfiguration;
    if (adConfig.adFormat == PBMAdFormatVideoInternal || adConfig.presentAsInterstitial) {
        return PBMSDKConfiguration.singleton.creativeFactoryTimeoutPreRenderContent;
    } else {
        return PBMSDKConfiguration.singleton.creativeFactoryTimeout;
    }
}

- (PBMDownloadDataHelper *)initializeDownloadDataHelper {
    return [[PBMDownloadDataHelper alloc] initWithPBMServerConnection:self.serverConnection];
}

- (PBMCreativeFactoryDownloadDataCompletionClosure)createLoader {
    id<PBMServerConnectionProtocol> const connection = self.serverConnection;
    PBMCreativeFactoryDownloadDataCompletionClosure result = ^(NSURL* _Nonnull  url, PBMDownloadDataCompletionClosure _Nonnull completionBlock) {
        PBMDownloadDataHelper *downloader = [[PBMDownloadDataHelper alloc] initWithPBMServerConnection:connection];
        [downloader downloadDataForURL:url completionClosure:^(NSData * _Nullable data, NSError * _Nullable error) {
            completionBlock ? completionBlock(data, error) : nil;
        }];
    };
    
    return result;
}

#pragma mark - PBMCreativeResolutionDelegate

- (void)creativeReady:(PBMAbstractCreative *)creative {
    [self successWithCreative:creative];
}

- (void)creativeFailed:(NSError *)error {
    [self failWithError:error];
}

@end
