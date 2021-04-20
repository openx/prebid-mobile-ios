//
//  PBMErrorTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMErrorTest: XCTestCase {
    func testErrorCollisions() {
        let allErrors = [
            PBMError.requestInProgress,
            
            PBMError.invalidAccountId,
            PBMError.invalidConfigId,
            PBMError.invalidSize,
            
            PBMError.serverError("some error reason"),
            
            PBMError.jsonDictNotFound,
            PBMError.responseDeserializationFailed,
            
            PBMError.noEventForNativeAdMarkupEventTracker,
            PBMError.noMethodForNativeAdMarkupEventTracker,
            PBMError.noUrlForNativeAdMarkupEventTracker,
            
            PBMError.noWinningBid,
            PBMError.noNativeCreative,
            
            PBMNativeAdAssetBoxingError.noDataInsideNativeAdMarkupAsset,
            PBMNativeAdAssetBoxingError.noImageInsideNativeAdMarkupAsset,
            PBMNativeAdAssetBoxingError.noTitleInsideNativeAdMarkupAsset,
            PBMNativeAdAssetBoxingError.noVideoInsideNativeAdMarkupAsset,
            
        ].map { $0 as NSError }
        
        for i in 1..<allErrors.count {
            for j in 0..<i {
                XCTAssertNotEqual(allErrors[i].code, allErrors[j].code,
                                  "\(i)('\(allErrors[i])' vs #\(j)('\(allErrors[j])'")
                XCTAssertNotEqual(allErrors[i].localizedDescription, allErrors[j].localizedDescription,
                                  "\(i)('\(allErrors[i])' vs #\(j)('\(allErrors[j])'")
            }
        }
    }
    
    func testErrorParsing() {
        let errors: [(Error?, PBMFetchDemandResult)] = [
            (PBMError.requestInProgress, .internalSDKError),
        
            (PBMError.invalidAccountId, .invalidAccountId),
            (PBMError.invalidConfigId, .invalidConfigId),
            (PBMError.invalidSize, .invalidSize),
        
            (PBMError.serverError("some error reason"), .serverError),
        
            (PBMError.jsonDictNotFound, .invalidResponseStructure),
            (PBMError.responseDeserializationFailed, .invalidResponseStructure),
            
            (PBMError.noWinningBid, .demandNoBids),
            
            (PBMError.noNativeCreative, .sdkMisuse_NoNativeCreative),
            
            (NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut), .demandTimedOut),
            (NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL), .networkError),
            
            (nil, .ok),
        ]
        
        for (error, code) in errors {
            XCTAssertEqual(PBMError.demandResult(fromError: error), code)
        }
    }
}
