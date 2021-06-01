//
//  InterstitialEventHandlerProtocol.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation


@objc public protocol InterstitialEventHandlerProtocol : PBMInterstitialAd {

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the ad server communication.
    @objc weak var loadingDelegate: InterstitialEventLoadingDelegate? { get set }

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the user's interaction with the ad.
    @objc weak var interactionDelegate: PBMInterstitialEventInteractionDelegate? { get set }

}
