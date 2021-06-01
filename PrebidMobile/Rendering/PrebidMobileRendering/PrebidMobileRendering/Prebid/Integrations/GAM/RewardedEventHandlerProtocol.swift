//
//  RewardedEventHandlerProtocol.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation


@objc public protocol RewardedEventHandlerProtocol: PBMInterstitialAd {

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the ad server communication.
    @objc weak var loadingDelegate: RewardedEventLoadingDelegate? { get set }

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the user's interaction with the ad.
    @objc weak var interactionDelegate: RewardedEventInteractionDelegate? { get set }

}
