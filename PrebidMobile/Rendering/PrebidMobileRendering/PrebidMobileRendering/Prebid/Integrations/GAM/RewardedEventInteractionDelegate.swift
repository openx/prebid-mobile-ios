//
//  RewardedEventInteractionDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol RewardedEventInteractionDelegate: PBMInterstitialEventInteractionDelegate {

    /*!
     @abstract Call this when the ad server SDK decides the use has earned reward
     */
    @objc func userDidEarnReward(_ reward: NSObject?)
}

