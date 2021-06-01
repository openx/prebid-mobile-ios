//
//  File.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

public class RewardedEventHandlerStandalone: NSObject, RewardedEventHandlerProtocol {
   
    public var loadingDelegate: PBMRewardedEventLoadingDelegate?
    public var interactionDelegate: PBMRewardedEventInteractionDelegate?
    
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
