//
//  PBMMediaViewT.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import UIKit

 let DEFAULT_VIEWABILITY_POLLING_INTERVAL: TimeInterval = 0.2
 let IGNORE_CLICKS_IF_UNREGISTERED = true

 enum PBMMediaViewStateT {
    case undefined, playbackNotStarted, playing, pausedByUser, pausedAuto, playbackFinished
}

@objc public protocol PPProto {
    func protomethod()
}

@objc public class TTView: UIView, PPProto {
    public func protomethod() {
        print("TEST!")
    }
}

@objc class TTT: UIView, PBMPlayable {
    public func canPlay() -> Bool {
        true
    }
    
    public func play() {
        
    }
    
    public func pause() {
        
    }
    
    public func autoPause() {
        
    }
    
    public func canAutoResume() -> Bool {
        true
    }
    
    public func resume() {
        
    }
    
    
}

@objcMembers public class PBMMediaViewT: UIView/*, PBMPlayable, PBMAdViewManagerDelegate*/ {

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
//            self.viewabilityPlaybackBinder = PBMViewabilityPlaybackBinder.init(exposureProvider: exposureProvider,
//                                                                               pollingInterval: pollingInterval,
//                                                                               scheduledTimerFactory: timerFactory,
//                                                                               playable: self)
        }
    }
    
     var shouldBindPlaybackToViewability: Bool {
        self.autoPlayOnVisible && self.mediaData != nil
    }
    // }
    
    var state: PBMMediaViewStateT = .undefined
    
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
        guard let adViewManager = adViewManager, isActive && adViewManager.isMuted == false else {
            return
        }
        adViewManager.mute()
//        delegate.onMediaPlaybackMuted(self)
    }
    
    public func unmute() {
    }
    
    // MARK: - PBMPlayable protocol
    public func canPlay() -> Bool {
        state == .playbackNotStarted
    }
    
    public func autoPause() {
    }
    
    public func canAutoResume() -> Bool {
        state == .pausedAuto
    }

    public func play() {
    }

    public func pause() {
    }
    
    public func resume() {
    }
    
    var isPaused: Bool { state == .pausedAuto || state == .pausedByUser }
    var isActive: Bool { state == .playing || isPaused }
    
    // MARK: - PBMAdViewManagerDelegate protocol
    
    public func viewControllerForModalPresentation() -> UIViewController? {
        let mediaData = self.mediaData ?? mediaDataToLoad
        let provider = mediaData?.nativeAdHooks.viewControllerProvider
        return provider != nil ? provider?() : nil
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
//        delegate.onMediaPlaybackFinished(self)
    }

    public func videoAdWasMuted() {
//        delegate.onMediaPlaybackMuted(self)
    }

    public func videoAdWasUnmuted() {
//        delegate.onMediaPlaybackUnmuted(self)
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
//        delegate.onMediaLoadingFinished(self)
    }

    func display(transaction: PBMTransaction?) {
        guard let transaction = transaction else {
            return
        }
        let connection = self.connection ?? PBMServerConnection.singleton()
        adViewManager = PBMAdViewManager(connection: connection, modalManagerDelegate: nil)
//        adViewManager?.adViewManagerDelegate = self
        adViewManager?.adConfiguration = adConfiguration
        adViewManager?.autoDisplayOnLoad = false
        adViewManager?.handleExternalTransaction(transaction)
    }

}
