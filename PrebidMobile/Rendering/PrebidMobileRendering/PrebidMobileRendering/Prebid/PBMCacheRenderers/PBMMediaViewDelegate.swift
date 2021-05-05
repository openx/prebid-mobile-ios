//
//  PBMMediaViewDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol PBMMediaViewDelegate {
    func onMediaPlaybackStarted(_ mediaView: MediaView)
    func onMediaPlaybackFinished(_ mediaView: MediaView)
    
    func onMediaPlaybackPaused(_ mediaView: MediaView)
    func onMediaPlaybackResumed(_ mediaView: MediaView)
    
    func onMediaPlaybackMuted(_ mediaView: MediaView)
    func onMediaPlaybackUnmuted(_ mediaView: MediaView)
    
    func onMediaLoadingFinished(_ mediaView: MediaView)
}
