//
//  GAMEventHandlerError.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

enum MoPubAdaptersError : Error {
    
    case emptyLocalExtras
    case unknown
    
    case gamClassesNotFound
    case noLocalCacheID
    case invalidLocalCacheID
    case invalidNativeAd
}

enum MoPubAdaptersErrorCodes : Int {

    case generalLinear  = 400
    case fileNotFound   = 401
    case nonLinearAds   = 500
    case general        = 700
    case undefined      = 900
    
}

fileprivate let MoPubAdaptersErrorDomain = "org.prebid.mobile.rendering.ErrorDomain";


fileprivate let errDescrEmptyLocalExtras = "The local extras is empty"
fileprivate let errDescrUnknown          = "Unknown error has been received."

fileprivate let errDescrClassNotFound   = "GoogleMobileAds SDK does not provide the required classes."
fileprivate let errDescrNoCacheID       = "Failed to find local cache ID (expected in ????."
fileprivate let errDescrInvalidCacheID  = "Invalid local cache ID or the Ad already expired."
fileprivate let errDescrInvalidNativeAd = "Failed to load Native Ad from cached bid response."

extension MoPubAdaptersError : LocalizedError {
    public var errorDescription: String? {
        switch self {
    
            case .emptyLocalExtras      : return errDescrEmptyLocalExtras
            case .unknown               : return errDescrUnknown
                
            case .gamClassesNotFound    : return errDescrClassNotFound
            case .noLocalCacheID        : return errDescrNoCacheID
            case .invalidLocalCacheID   : return errDescrInvalidCacheID
            case .invalidNativeAd       : return errDescrInvalidNativeAd
        }
    }
}

extension MoPubAdaptersError :  CustomNSError {
    static var errorDomain: String {
        MoPubAdaptersErrorDomain
    }
    
    public var errorCode: Int {
        switch self {
            case .emptyLocalExtras      : return MoPubAdaptersErrorCodes.general.rawValue
            case .unknown               : return MoPubAdaptersErrorCodes.undefined.rawValue

            case .gamClassesNotFound    : return MoPubAdaptersErrorCodes.undefined.rawValue
            case .noLocalCacheID        : return MoPubAdaptersErrorCodes.undefined.rawValue
            case .invalidLocalCacheID   : return MoPubAdaptersErrorCodes.undefined.rawValue
            case .invalidNativeAd       : return MoPubAdaptersErrorCodes.undefined.rawValue
        }
    }

}