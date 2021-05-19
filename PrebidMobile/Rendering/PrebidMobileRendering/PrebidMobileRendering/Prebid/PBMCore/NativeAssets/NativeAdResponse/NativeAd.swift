//
//  NativeAd.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

fileprivate let viewabilityPollingInterval : TimeInterval = 0.2


public class NativeAd: NSObject {
    
    @objc public weak var uiDelegate: PBMNativeAdUIDelegate?
    @objc public weak var trackingDelegate: PBMNativeAdTrackingDelegate?
    
    // MARK: - Root properties
    
    @objc public var version: String { nativeAdMarkup!.version ?? ""}
    
    
    // MARK: - Convenience getters

    @objc public var title: String {
        let titles = self.titles
        let title = (titles.count > 0) ? titles[0].text : nil
        return title ?? ""
    }
    
    @objc public var text: String {
        let descriptions = self.dataObjects(of: .desc)
        let description = (descriptions.count > 0) ? descriptions[0].value : nil
        return description ?? ""
    }
    
    @objc public var iconURL: String {
        let icons = self.images(of: .icon)
        let icon = (icons.count > 0) ? icons[0].url : nil
        return icon ?? ""
    }
    
    @objc public var imageURL: String {
        let images = self.images(of: .main)
        let image = (images.count > 0) ? images[0].url : nil
        return image ?? ""
    }
    
    @objc public var videoAd: NativeAdVideo? {
        let videoAds = self.videoAds
        return videoAds.count > 0 ? videoAds[0] : nil
    }
    
    @objc public var callToAction: String {
        let callToActions = self.dataObjects(of: .ctaText)
        let callToAction = (callToActions.count > 0) ? callToActions[0].value : nil
        return callToAction ?? ""
    }
    
    
    // MARK: - Array getters
    
    @objc public var titles: [NativeAdTitle] {
        nativeAdMarkup!.assets?.compactMap { try? NativeAdTitle(nativeAdMarkupAsset: $0) } ?? []
    }
    
    @objc public var dataObjects: [NativeAdData] {
        nativeAdMarkup!.assets?.compactMap { try? NativeAdData(nativeAdMarkupAsset: $0) } ?? []
    }
    
    @objc public var images: [NativeAdImage] {
        nativeAdMarkup!.assets?.compactMap { try? NativeAdImage(nativeAdMarkupAsset: $0) } ?? []
    }
    
    @objc public var videoAds: [NativeAdVideo] {
        guard let assets = nativeAdMarkup.assets else {
            return []
        }
        var result: [NativeAdVideo] = []
        
        let viewControllerProvider: PBMViewControllerProvider = { [weak self] in
            if let self = self {
                return self.uiDelegate?.viewPresentationController(for: self)
            } else {
                return nil
            }
        }
        let nativeClickHandler = self.nativeClickHandlerBlock
        for nextAsset in assets {
            let markupLink = nextAsset.link ?? self.nativeAdMarkup.link
            var clickHandlerOverride: PBMCreativeClickHandlerBlock //? = nil
            if let linkUrl = markupLink?.url {
                clickHandlerOverride = { onClickthroughExitBlock in
                    nativeClickHandler?(linkUrl, markupLink?.fallback, markupLink?.clicktrackers, onClickthroughExitBlock)
                }
            } else {
                clickHandlerOverride = { _ in  }
            }
            let nativeAdHooks = PBMNativeAdMediaHooks(viewControllerProvider: viewControllerProvider,
                                                      clickHandlerOverride: clickHandlerOverride)
            if let nextVideo = try? NativeAdVideo(nativeAdMarkupAsset: nextAsset, nativeAdHooks: nativeAdHooks) {
                result.append(nextVideo)
            }
            
        }
        return result
    }
    
    @objc public var imptrackers: [String] { self.nativeAdMarkup.imptrackers ?? [] }
    
    
    // MARK: - Filtered array getters
    
    @objc public func dataObjects(of dataType: PBMDataAssetType) -> [NativeAdData] {
        dataObjects.filter { $0.dataType?.intValue == dataType.rawValue }
    }

    @objc public func images(of imageType: PBMImageAssetType) -> [NativeAdImage] {
        images.filter { $0.imageType?.intValue == imageType.rawValue }
    }
    
    // MARK: - Private properties
    
    private var nativeAdMarkup: PBMNativeAdMarkup!
    
    private var fireEventTrackersBlock: PBMNativeImpressionDetectionHandler!
    private var nativeClickHandlerBlock: PBMNativeViewClickHandlerBlock!
    private var clickableViewRegistry: PBMNativeClickableViewRegistry!
    
    private var impressionTracker: PBMNativeImpressionsTracker?
    private var measurementWrapper: PBMOpenMeasurementWrapper!
    private var measurementSession: PBMOpenMeasurementSession?
    
    
    // MARK: - Lifecycle
    
    init(nativeAdMarkup: PBMNativeAdMarkup,
         application: PBMUIApplicationProtocol,
         measurementWrapper: PBMOpenMeasurementWrapper,
         serverConnection: PBMServerConnectionProtocol,
         sdkConfiguration: PBMSDKConfiguration) {
            
        self.nativeAdMarkup = nativeAdMarkup
        
        super.init()
        
        let appUrlOpener = PBMExternalURLOpeners.application(asExternalUrlOpener: application)
        let trackingUrlVisitor = PBMTrackingURLVisitors.connection(asTrackingURLVisitor: serverConnection)
        let appUrlLinkHandler  = PBMExternalLinkHandler(primaryUrlOpener: appUrlOpener,
                                                        deepLinkUrlOpener: appUrlOpener,
                                                        trackingUrlVisitor: trackingUrlVisitor)
        let modalManager = PBMModalManager()
        
        let clickthroughOpener = PBMClickthroughBrowserOpener(sdkConfiguration: sdkConfiguration,
                                                              adConfiguration: nil,
                                                              modalManager: modalManager,
                                                              viewControllerProvider: {[weak self] in
            guard let self = self else {
                return nil
            }
            let delegate = self.uiDelegate
            return delegate?.viewPresentationController(for: self)
        },
        measurementSessionProvider: { [weak self] in
            self?.measurementSession
        },
        onWillLoadURLInClickthrough: { [weak self] in
            if let self = self, let delegate = self.uiDelegate {
                delegate.nativeAdWillPresentModal?(self)
            }
        },
        onWillLeaveAppBlock: {[weak self] in
            if let self = self, let delegate = self.uiDelegate {
                delegate.nativeAdWillLeaveApplication?(self)
            }
        },
        onClickthroughPoppedBlock: {[weak self] _ in
            if let self = self, let delegate = self.uiDelegate {
                delegate.nativeAdDidDismissModal?(self)
            }
        },
        onDidLeaveAppBlock: {[weak self] _ in
            if let self = self, let delegate = self.uiDelegate {
                delegate.nativeAdWillLeaveApplication?(self)
            }
        })
        
        let clickthroughLinkHandler = appUrlLinkHandler.addingUrlOpenAttempter(clickthroughOpener.asUrlOpenAttempter())
        
        // TODO: Enable 'deeplink+' support
        #if DEBUG
        // Note: keep unused variable to ensure the code compiles for later use
        let _ = PBMDeepLinkPlusHelper.deepLinkPlusHandler(with: clickthroughLinkHandler)
        #endif
        
        let externalLinkHandler = clickthroughLinkHandler
        
        self.fireEventTrackersBlock = PBMNativeAdImpressionReporting.impressionReporter(with: nativeAdMarkup.eventtrackers ?? [],
                                                                                        urlVisitor: trackingUrlVisitor)
        
        let reportSelfClicked: PBMVoidBlock = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.trackOMEvent(.click)
            if let delegate = self.trackingDelegate {
                delegate.nativeAdDidLogClick?(self)
            }
        }
        
        let nativeClickHandler: PBMNativeViewClickHandlerBlock = { url,
                                                                   fallback,
                                                                   clicktrackers,
                                                                   onClickthroughExitBlock in
            let tryFallbackUrl: PBMVoidBlock = {
                if let fallbackUrl = URL(string: fallback ?? "") {
                    externalLinkHandler.openExternalUrl(fallbackUrl,
                                                        trackingUrls: clicktrackers,
                                                        completion: { _ in
                                                            reportSelfClicked()
                                                        },
                                                        onClickthroughExitBlock: onClickthroughExitBlock)
                } else {
                    reportSelfClicked()
                }
            }
            if let mainUrl = URL(string: url) {
                externalLinkHandler.openExternalUrl(mainUrl,
                                                    trackingUrls: clicktrackers,
                                                    completion: { success in
                                                        if success {
                                                            reportSelfClicked()
                                                        } else {
                                                            tryFallbackUrl()
                                                        }
                                                    },
                                                    onClickthroughExitBlock: onClickthroughExitBlock)
            } else {
                tryFallbackUrl()
            }
        }
        
        let clickBinderFactory = PBMNativeClickTrackerBinders.smartBinder
        
        self.nativeClickHandlerBlock = nativeClickHandler
        self.clickableViewRegistry = PBMNativeClickableViewRegistry(binderFactory: clickBinderFactory,
                                                                    clickHandler: nativeClickHandler)
        
        self.measurementWrapper = measurementWrapper
    }
    
    @objc public convenience init(nativeAdMarkup: PBMNativeAdMarkup) {
        self.init(nativeAdMarkup: nativeAdMarkup,
                  application: UIApplication.shared,
                  measurementWrapper: PBMOpenMeasurementWrapper.singleton,
                  serverConnection: PBMServerConnection.singleton(),
                  sdkConfiguration: PBMSDKConfiguration.singleton)
    }

    // MARK: - Overrides
    private override init() {
    }
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        let other = object as? NativeAd
        return (self === other) || (nativeAdMarkup == other?.nativeAdMarkup)
    }

    // MARK: - View handling
    @objc public func registerView(_ adView: UIView, clickableViews: [UIView]?) {
        guard impressionTracker == nil else {
            return
        }
        
        self.impressionTracker = PBMNativeImpressionsTracker(view: adView,
                                                             pollingInterval: viewabilityPollingInterval,
                                                             scheduledTimerFactory: Timer.pbmScheduledTimerFactory(),
                                                             impressionDetectionHandler: { [weak self] impressionType in
            guard let self = self else {
                return
            }
            
            if impressionType == .impression {
                self.trackOMEvent(.impression)
            }
                                                                
            self.fireEventTrackersBlock(impressionType)
            if let delegate = self.trackingDelegate {
                delegate.nativeAd?(self, didLogEvent: impressionType)
            }
        })
        
        if let clickableViews = clickableViews, let link = nativeAdMarkup.link {
            for nextView in clickableViews {
                self.clickableViewRegistry .register(link, for: nextView)
            }
        }
        
        self.createOpenMeasurementSessionFor(adView)
    }

    @objc public func registerClickView(_ adView: UIView, nativeAdElementType: PBMNativeAdElementType) {
        if let relevantAsset = self.findAssetForElementType(nativeAdElementType) {
            self.registerClickView(adView, nativeAdAsset: relevantAsset)
        }
    }

    @objc public func registerClickView(_ adView: UIView, nativeAdAsset: NativeAdAsset) {
        let relevantLink = nativeAdAsset.link ?? self.nativeAdMarkup.link
        if let relevantLink = relevantLink {
            self.clickableViewRegistry.register(relevantLink, for: adView)
        }
    }
    
    // MARK: - Private Helpers
    func findAssetForElementType(_ nativeAdElementType: PBMNativeAdElementType) -> NativeAdAsset? {
        var assets: [NativeAdAsset]? = nil
        switch(nativeAdElementType) {
            case .title:
                assets = self.titles
            case .text:
                assets = self.dataObjects(of: .desc)
            case .icon:
                assets = self.images(of: .icon)
            case .image:
                assets = self.images(of: .main)
            case .videoAd:
                assets = self.videoAds
            case .callToAction:
                assets = self.dataObjects(of: .ctaText)
        }
        if let assets = assets {
            return assets.count > 0 ? assets[0] : nil
        }
        return nil
    }
    
    // MARK: - Private Helpers (OpenMeasurement support)
    func createOpenMeasurementSessionFor(_ adView: UIView) {
        guard Thread.current.isMainThread else {
            PBMLog.error("Open Measurement session can only be created on the main thread")
            return
        }
        
        if let omTracker = self.findOMIDTracker(), let jsUrl = omTracker.url {
            self.measurementSession = self.measurementWrapper.initializeNativeDisplaySession(adView,
                                                        omidJSUrl: jsUrl,
                                                        vendorKey: omTracker.ext?["vendorKey"] as? String,
                                                        parameters: omTracker.ext?["verification_parameters"]  as? String)
            self.measurementSession?.start()
        }
    }
    
    func findOMIDTracker() -> PBMNativeAdMarkupEventTracker? {
        nativeAdMarkup.eventtrackers?.first {$0.event == .OMID && $0.method == .JS && $0.url != nil}
    }
    
    func trackOMEvent(_ event: PBMTrackingEvent) {
        guard let measurementSession = self.measurementSession else {
            PBMLog.error("Measurement Session is missed.")
            return
        }
        
        if event == .impression {
            measurementSession.eventTracker.trackEvent(.loaded)
        }
        measurementSession.eventTracker.trackEvent(event)
    }
}
