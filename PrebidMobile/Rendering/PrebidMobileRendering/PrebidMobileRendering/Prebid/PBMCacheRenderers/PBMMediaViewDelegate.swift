//
//  PBMMediaViewDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

protocol PBMMediaViewDelegateT: NSObject {
    func onMediaPlaybackStarted(mediaView: PBMMediaView)
    func onMediaPlaybackFinished(mediaView: PBMMediaView)
    
    func onMediaPlaybackPaused(mediaView: PBMMediaView)
    func onMediaPlaybackResume(mediaView: PBMMediaView)
    
    func onMediaPlaybackMuted(mediaView: PBMMediaView)
    func onMediaPlaybackUnmuted(mediaView: PBMMediaView)
    
    func onMediaLoadingFinished(mediaView: PBMMediaView)
}
