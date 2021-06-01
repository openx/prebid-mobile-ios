//
//  InterstitialControllerLoadingDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol InterstitialControllerLoadingDelegate where Self: NSObject {

    @objc func interstitialControllerDidLoadAd(_ interstitialController: InterstitialController)
    @objc func interstitialController(_ interstitialController: InterstitialController,
                                      didFailWithError error: Error)
}
