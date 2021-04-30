//
//  PBMMediaViewT.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import UIKit

 let DEFAULT_VIEWABILITY_POLLING_INTERVAL: TimeInterval = 0.2
 let IGNORE_CLICKS_IF_UNREGISTERED = true

 enum MediaViewState {
    case undefined, playbackNotStarted, playing, pausedByUser, pausedAuto, playbackFinished
}

@objcMembers public class PBMMediaView: UIView, PBMPlayable, PBMAdViewManagerDelegate {
    
    @IBInspectable public var autoPlayOnVisible: Bool {
        get { rawAutoPlayOnVisible }
        set {
            rawAutoPlayOnVisible = newValue;
            bindPlaybackToViewability = shouldBindPlaybackToViewability
        }
    }
    
    @IBInspectable public weak var delegate: PBMMediaViewDelegate?
    
    // FIXME: do we need this ??
    public var isMediaLoaded: Bool {
        get { true }
    }
    
    private(set) public var mediaData: PBMMediaData?    // filled on successful load
    var mediaDataToLoad: PBMMediaData?          // present during the loading
    
    var adConfiguration: PBMAdConfiguration!    // created on media loading attempt
    
    // TODO: make available only tests {
    var connection: PBMServerConnectionProtocol?
    var pollingInterval: NSNumber?  // NSTimeInterval
    var scheduledTimerFactory: PBMScheduledTimerFactory?
    // }
    
    // Ad loading and management {
    var vastTransactionFactory: PBMVastTransactionFactory!
    var adViewManager: PBMAdViewManager?
    // }
    
    // autoPlayOnVisible {
    var rawAutoPlayOnVisible = true
    
    var viewabilityPlaybackBinder: PBMViewabilityPlaybackBinder?
    
    var bindPlaybackToViewability: Bool {
        get { self.viewabilityPlaybackBinder != nil }
        set(bindPlaybackToViewability) {
            if !bindPlaybackToViewability {
                // -> turn OFF
                self.viewabilityPlaybackBinder = nil;
                return;
            }
            if self.viewabilityPlaybackBinder != nil {
                // already ON
                return;
            }
            // -> turn ON
            let exposureProvider = PBMViewExposureProviders.visibilityAsExposure(for: self)
            let pollingInterval = self.pollingInterval?.doubleValue ?? DEFAULT_VIEWABILITY_POLLING_INTERVAL
            let timerFactory = self.scheduledTimerFactory ?? Timer.pbmScheduledTimerFactory()
            self.viewabilityPlaybackBinder = PBMViewabilityPlaybackBinder.init(exposureProvider: exposureProvider,
                                                                               pollingInterval: pollingInterval,
                                                                               scheduledTimerFactory: timerFactory,
                                                                               playable: self)
        }
    }
    
     var shouldBindPlaybackToViewability: Bool {
        self.autoPlayOnVisible && self.mediaData != nil
    }
    // }
    
    var state: MediaViewState = .undefined
    
    public func loadMedia(_ mediaData: PBMMediaData) {
        
        guard self.mediaData == nil else {
            reportFailureWithError(PBMError.replacingMediaDataInMediaView, markLoadingStopped: false)
            return
        }
        
        guard self.vastTransactionFactory == nil && self.mediaDataToLoad == nil else {
            // the Ad is being loaded
            return
        }
        
        guard let vasttag = mediaData.mediaAsset.video?.vasttag else {
            reportFailureWithError(PBMError.noVastTagInMediaData, markLoadingStopped: true)
            return
        }
        
        state = .undefined
        mediaDataToLoad = mediaData
        adConfiguration = PBMAdConfiguration()
        adConfiguration.adFormat = .videoInternal
        adConfiguration.isNative = true
        adConfiguration.isInterstitialAd = false
        adConfiguration.isBuiltInVideo = true
        
        if (IGNORE_CLICKS_IF_UNREGISTERED) {
            adConfiguration.clickHandlerOverride =  { onClickthroughExitBlock in
                // nop
                onClickthroughExitBlock();
            }
        } else {
            adConfiguration.clickHandlerOverride = mediaData.nativeAdHooks.clickHandlerOverride;
        }
        
        let connection = self.connection ?? PBMServerConnection.singleton()
        vastTransactionFactory = PBMVastTransactionFactory(connection: connection,
                                                                adConfiguration: adConfiguration,
                                                                callback: { [weak self] transaction, error in
            guard let self = self else {
                return
            }
                                                                    
            if error != nil {
                self.reportFailureWithError(error, markLoadingStopped: true)
            } else {
                self.display(transaction: transaction)
            }
                                                                    
        })
        
        vastTransactionFactory.load(withAdMarkup: vasttag)
    }
    
    public func mute() {
        guard let adViewManager = self.adViewManager, isActive && !adViewManager.isMuted else {
            return
        }
        adViewManager.mute()
        delegate?.onMediaPlaybackMuted(self)
    }
    
    public func unmute() {
        guard let adViewManager = self.adViewManager, isActive && adViewManager.isMuted else {
            return
        }
        adViewManager.unmute()
        delegate?.onMediaPlaybackUnmuted(self)
    }
    
    // MARK: - PBMPlayable protocol
    public func canPlay() -> Bool {
        state == .playbackNotStarted
    }
    
    public func play() {
        guard canPlay(), let adViewManager = self.adViewManager  else {
            return
        }
        state = .playing
        adViewManager.show()
        delegate?.onMediaPlaybackStarted(self)
    }

    public func pause() {
        self.pauseWith(state: .pausedByUser)
    }
    
    public func autoPause() {
        self.pauseWith(state: .pausedAuto)
    }
    
    func pauseWith(state: MediaViewState) {
        guard state == .playing, let adViewManager = self.adViewManager  else {
            return
        }
        self.state = state
        adViewManager.pause()
        delegate?.onMediaPlaybackPaused(self)
    }
    
    public func canAutoResume() -> Bool {
        state == .pausedAuto
    }
    
    public func resume() {
        guard isPaused, let adViewManager = self.adViewManager  else {
            return
        }
        state = .playing
        adViewManager.resume()
        delegate?.onMediaPlaybackResumed(self)
    }
    
    var isPaused: Bool { state == .pausedAuto || state == .pausedByUser }
    var isActive: Bool { state == .playing || isPaused }
    
    // MARK: - PBMAdViewManagerDelegate protocol
    
    public func viewControllerForModalPresentation() -> UIViewController {
        let mediaData = self.mediaData ?? mediaDataToLoad
        let provider = mediaData?.nativeAdHooks.viewControllerProvider
//        return provider != nil ? provider?() : nil
//        return (provider != nil ?
//            provider?() :
//            UIViewController()) as! UIViewController
        
        return provider?() ?? UIViewController()
    }
    
    public func adLoaded(_ pbmAdDetails: PBMAdDetails) {
        state = .playbackNotStarted
        reportSuccess()
    }

    public func failed(toLoad error: Error) {
        reportFailureWithError(error, markLoadingStopped: true)
    }

    public func adDidComplete() {
        // FIXME: Implement
    }

    public func videoAdDidFinish() {
        state = .playbackFinished
        delegate?.onMediaPlaybackFinished(self)
    }

    public func videoAdWasMuted() {
        delegate?.onMediaPlaybackMuted(self)
    }

    public func videoAdWasUnmuted() {
        delegate?.onMediaPlaybackUnmuted(self)
    }

    public func adDidDisplay() {
        // FIXME: Implement
    }

    public func adWasClicked() {
        // FIXME: Implement
    }

    public func adViewWasClicked() {
        // FIXME: Implement
    }

    public func adDidExpand() {
        // FIXME: Implement
    }

    public func adDidCollapse() {
        // FIXME: Implement
    }

    public func adDidLeaveApp() {
        // FIXME: Implement
    }

    public func adClickthroughDidClose() {
        // FIXME: Implement
    }

    public func adDidClose() {
        // FIXME: Implement
    }

    func display() -> UIView { self }
    
    // MARK: - Private Helpers

    func reportFailureWithError(_ error: Error?, markLoadingStopped: Bool) {
        if markLoadingStopped {
            vastTransactionFactory = nil
            mediaDataToLoad = nil
        }
    }

    func reportSuccess() {
        mediaData = mediaDataToLoad
        vastTransactionFactory = nil
        bindPlaybackToViewability = shouldBindPlaybackToViewability
        delegate?.onMediaLoadingFinished(self)
    }

    func display(transaction: PBMTransaction?) {
        guard let transaction = transaction else {
            return
        }
        let connection = self.connection ?? PBMServerConnection.singleton()
        adViewManager = PBMAdViewManager(connection: connection, modalManagerDelegate: nil)
        adViewManager?.adViewManagerDelegate = self
        adViewManager?.adConfiguration = adConfiguration
        adViewManager?.autoDisplayOnLoad = false
        adViewManager?.handleExternalTransaction(transaction)
    }

}
