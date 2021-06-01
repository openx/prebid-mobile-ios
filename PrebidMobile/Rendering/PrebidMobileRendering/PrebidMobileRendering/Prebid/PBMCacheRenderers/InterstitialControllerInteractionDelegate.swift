//
//  InterstitialControllerInteractionDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol InterstitialControllerInteractionDelegate where Self : NSObject {

@objc func trackImpression(for interstitialController:InterstitialController)

    @objc func interstitialControllerDidClickAd(_ interstitialController: InterstitialController)
    @objc func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController)
    @objc func interstitialControllerDidLeaveApp(_ interstitialController: InterstitialController)
    @objc func interstitialControllerDidDisplay(_ interstitialController: InterstitialController)
    @objc func interstitialControllerDidComplete(_ interstitialController: InterstitialController)

    @objc func viewControllerForModalPresentation(from interstitialController: InterstitialController) -> UIViewController?
}
