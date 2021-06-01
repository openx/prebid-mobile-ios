//
//  InterstitialEventHandlerStandalone.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

public class InterstitialEventHandlerStandalone: NSObject, InterstitialEventHandlerProtocol {
    
    // MARK: Public Methods
    
    public var loadingDelegate: InterstitialEventLoadingDelegate?
    
    public var interactionDelegate: PBMInterstitialEventInteractionDelegate?
    
    public var isReady: Bool {
        false
    }
    
    public func show(from controller: UIViewController?) {
        assertionFailure("should never be called, as PBM SDK always wins")
    }
    
    public func requestAd(with bidResponse: BidResponse?) {
        loadingDelegate?.prebidDidWin()
    }
    
    
}
