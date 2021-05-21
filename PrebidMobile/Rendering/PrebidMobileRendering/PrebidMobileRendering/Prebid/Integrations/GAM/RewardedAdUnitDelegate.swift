//
//  RewardedAdUnitDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc protocol PBMRewardedAdUnitDelegate111: NSObjectProtocol {
    @objc optional func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit)
    @objc optional func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit)
    @objc optional func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?)
}
