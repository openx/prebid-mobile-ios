//
//  InterstitialEventLoadingDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

/*!
 The interstitial custom event delegate. It is used to inform ad server events back to the OpenWrap SDK
 */
@objc public protocol InterstitialEventLoadingDelegate where Self: NSObject {

    /*!
     @abstract Call this when the ad server SDK signals about partner bid win
     */
    @objc func prebidDidWin()

    /*!
     @abstract Call this when the ad server SDK renders its own ad
     */
    @objc func adServerDidWin()

    /*!
     @abstract Call this when the ad server SDK fails to load the ad
     @param error detailed error object describing the cause of ad failure
     */
    @objc func failedWithError(_ error: Error?)
}
