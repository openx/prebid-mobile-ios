//
//  PBMMediaViewDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol PBMMediaViewDelegate {
    func onMediaPlaybackStarted(_ mediaView: PBMMediaView)
    func onMediaPlaybackFinished(_ mediaView: PBMMediaView)
    
    func onMediaPlaybackPaused(_ mediaView: PBMMediaView)
    func onMediaPlaybackResumed(_ mediaView: PBMMediaView)
    
    func onMediaPlaybackMuted(_ mediaView: PBMMediaView)
    func onMediaPlaybackUnmuted(_ mediaView: PBMMediaView)
    
    func onMediaLoadingFinished(_ mediaView: PBMMediaView)
}
