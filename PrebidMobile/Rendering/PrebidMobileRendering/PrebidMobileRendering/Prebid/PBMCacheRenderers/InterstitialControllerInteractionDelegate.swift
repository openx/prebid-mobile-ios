//
//  InterstitialControllerInteractionDelegate.swift
/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import UIKit

@objc public protocol InterstitialControllerInteractionDelegate where Self : NSObject {

    func trackImpression(for interstitialController:InterstitialController)

    func interstitialControllerDidClickAd(_ interstitialController: InterstitialController)
    func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController)
    func interstitialControllerDidLeaveApp(_ interstitialController: InterstitialController)
    func interstitialControllerDidDisplay(_ interstitialController: InterstitialController)
    func interstitialControllerDidComplete(_ interstitialController: InterstitialController)

    func viewControllerForModalPresentation(from interstitialController: InterstitialController) -> UIViewController?
}
