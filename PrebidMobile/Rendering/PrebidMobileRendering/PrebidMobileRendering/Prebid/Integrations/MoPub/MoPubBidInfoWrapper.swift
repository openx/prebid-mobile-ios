//
//  MoPubBidInfoWrapper.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class MoPubBidInfoWrapper : NSObject, PBMMoPubAdObjectProtocol {
    public var keywords: String?
    public var localExtras: [AnyHashable : Any]?
}
