//
//  DisplayViewInteractionDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol DisplayViewInteractionDelegate where Self: NSObject {

    @objc func trackImpression(for displayView:PBMDisplayView)
    
    @objc func viewControllerForModalPresentation(from displayView: PBMDisplayView) -> UIViewController?
    
    @objc func didLeaveApp(from displayView: PBMDisplayView)
    
    @objc func willPresentModal(from displayView: PBMDisplayView)
    
    @objc func didDismissModal(from displayView: PBMDisplayView)
}
