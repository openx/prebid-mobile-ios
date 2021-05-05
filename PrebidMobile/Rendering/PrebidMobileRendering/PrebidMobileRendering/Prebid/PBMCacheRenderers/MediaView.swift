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

@objc(PBMMediaView) public class MediaView: UIView, PBMPlayable, PBMAdViewManagerDelegate {
    
    @IBInspectable @objc public weak var delegate: PBMMediaViewDelegate?
    
    @objc private(set) public var mediaData: MediaData?    // filled on successful load
    var mediaDataToLoad: MediaData?          // present during the loading
    
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
    @IBInspectable @objc public var autoPlayOnVisible = true {
        didSet {
            bindPlaybackToViewability = shouldBindPlaybackToViewability
        }
    }
    
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
    
    @objc public func loadMedia(_ mediaData: MediaData) {
        
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
    
    @objc public func mute() {
        guard let adViewManager = self.adViewManager, isActive && !adViewManager.isMuted else {
            return
        }
        adViewManager.mute()
        delegate?.onMediaPlaybackMuted(self)
    }
    
    @objc public func unmute() {
        guard let adViewManager = self.adViewManager, isActive && adViewManager.isMuted else {
            return
        }
        adViewManager.unmute()
        delegate?.onMediaPlaybackUnmuted(self)
    }
    
    // MARK: - PBMPlayable protocol
    @objc public func canPlay() -> Bool {
        state == .playbackNotStarted
    }
    
    @objc public func play() {
        guard canPlay(), let adViewManager = self.adViewManager  else {
            return
        }
        state = .playing
        adViewManager.show()
        delegate?.onMediaPlaybackStarted(self)
    }

    @objc public func pause() {
        self.pauseWith(state: .pausedByUser)
    }
    
    @objc public func autoPause() {
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
    
    @objc public func canAutoResume() -> Bool {
        state == .pausedAuto
    }
    
    @objc public func resume() {
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
    
    @objc public func viewControllerForModalPresentation() -> UIViewController? {
        let mediaData = self.mediaData ?? mediaDataToLoad
        let provider = mediaData?.nativeAdHooks.viewControllerProvider
        return provider?() ?? UIViewController()
    }
    
    @objc public func adLoaded(_ pbmAdDetails: PBMAdDetails) {
        state = .playbackNotStarted
        reportSuccess()
    }

    @objc public func failed(toLoad error: Error) {
        reportFailureWithError(error, markLoadingStopped: true)
    }

    @objc public func adDidComplete() {
        // FIXME: Implement
    }

    @objc public func videoAdDidFinish() {
        state = .playbackFinished
        delegate?.onMediaPlaybackFinished(self)
    }

    @objc public func videoAdWasMuted() {
        delegate?.onMediaPlaybackMuted(self)
    }

    @objc public func videoAdWasUnmuted() {
        delegate?.onMediaPlaybackUnmuted(self)
    }

    @objc public func adDidDisplay() {
        // FIXME: Implement
    }

    @objc public func adWasClicked() {
        // FIXME: Implement
    }

    @objc public func adViewWasClicked() {
        // FIXME: Implement
    }

    @objc public func adDidExpand() {
        // FIXME: Implement
    }

    @objc public func adDidCollapse() {
        // FIXME: Implement
    }

    @objc public func adDidLeaveApp() {
        // FIXME: Implement
    }

    @objc public func adClickthroughDidClose() {
        // FIXME: Implement
    }

    @objc public func adDidClose() {
        // FIXME: Implement
    }

    @objc public func displayView() -> UIView { self }
    
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
