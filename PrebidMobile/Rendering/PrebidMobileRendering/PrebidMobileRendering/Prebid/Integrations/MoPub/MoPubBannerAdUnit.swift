//
//  MoPubBannerAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

public class MoPubBannerAdUnit : NSObject {
    
    var bidRequester: PBMBidRequester?
    //This is an MPAdView object
    //But we can't use it indirectly as don't want to have additional MoPub dependency in the SDK core
    weak var adObject: NSObject?
    var completion: ((PBMFetchDemandResult) -> Void)?

    weak var lastAdObject: NSObject?
    var lastCompletion: ((PBMFetchDemandResult) -> Void)?

    var isRefreshStopped = false
    var autoRefreshManager: PBMAutoRefreshManager?

    var  adRequestError: Error?
    
    var adUnitConfig: PBMAdUnitConfig
    
    // MARK: - Computed properties

    var configID: String {
        adUnitConfig.configId;
    }

    var adFormat: PBMAdFormat {
        get { adUnitConfig.adFormat }
        set { adUnitConfig.adFormat = newValue }
    }

    var adPosition: PBMAdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    var videoPlacementType: PBMVideoPlacementType {
        get { adUnitConfig.videoPlacementType }
        set { adUnitConfig.videoPlacementType = newValue }
    }

    var nativeAdConfig: PBMNativeAdConfiguration? {
        get { adUnitConfig.nativeAdConfig }
        set { adUnitConfig.nativeAdConfig = newValue }
    }

    var refreshInterval: TimeInterval {
        get { adUnitConfig.refreshInterval }
        set { adUnitConfig.refreshInterval = newValue }
    }

    var additionalSizes: [NSValue]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    // MARK: - Public Methods
    
    init(configID: String, size: CGSize) {
        adUnitConfig = PBMAdUnitConfig(configId: configID, size: size)
        
        super.init()

        autoRefreshManager = PBMAutoRefreshManager(prefetchTime: PBMAdPrefetchTime,
                                                   locking: nil,
                                                   lockProvider: nil,
                                                   refreshDelay: { [weak self] in
                                                    (self?.adUnitConfig.refreshInterval ?? 0) as NSNumber
                                                   },
                                                   mayRefreshNowBlock: { [weak self] in
                                                    guard let self = self else { return false }
                                                    return self.isAdObjectVisible() || self.adRequestError != nil
                                                   }, refreshBlock: { [weak self] in
                                                    guard let self = self,
                                                          let adObject = self.lastAdObject,
                                                          let completion = self.lastCompletion else {
                                                        return
                                                    }
                                                    
                                                    self.fetchDemand(with: adObject,
                                                                     connection: PBMServerConnection.singleton(),
                                                                     sdkConfiguration: PBMSDKConfiguration.singleton,
                                                                     targeting: PBMTargeting.shared(),
                                                                     completion: completion)
                                                    
                                                   })
    }
    
    public func fetchDemand(with adObject: NSObject,
                            completion: ((PBMFetchDemandResult)->Void)?) {
        
        fetchDemand(with: adObject,
                    connection: PBMServerConnection.singleton(),
                    sdkConfiguration: PBMSDKConfiguration.singleton,
                    targeting: PBMTargeting.shared(),
                    completion: completion)
    }

    // MARK: Private functions
    
    private func fetchDemand(with adObject: NSObject,
                             connection: PBMServerConnectionProtocol,
                             sdkConfiguration: PBMSDKConfiguration,
                             targeting: PBMTargeting,
                             completion: ((PBMFetchDemandResult)->Void)?) {
        guard bidRequester == nil else {
            // Request in progress
            return
        }
        
        guard PBMMoPubUtils.isCorrectAdObject(adObject) else {
            completion?(.wrongArguments)
            return;
        }
        
        autoRefreshManager?.cancelRefreshTimer()
        
        if isRefreshStopped {
            return
        }
        
        self.adObject = adObject
        self.completion = completion
        
        lastAdObject = nil
        lastCompletion = nil
        adRequestError = nil
        
        if let moPubObject = self.adObject as? PBMMoPubAdObjectProtocol {
            PBMMoPubUtils.cleanUpAdObject(moPubObject)
        }
        
        bidRequester = PBMBidRequester(connection: connection,
                                       sdkConfiguration: sdkConfiguration,
                                       targeting: targeting,
                                       adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids(completion: { [weak self] bidResponse, error in
            guard let self = self else { return }
            
            if self.isRefreshStopped {
                self.markLoadingFinished()
                return
            }
            
            if let response = bidResponse {
                self.handlePrebidResponse(response: response)
            } else {
                self.handlePrebidError(error: error)
            }
        })
    }
    
    private func isAdObjectVisible() -> Bool {
        if let adObject = lastAdObject as? UIView {
            return adObject.pbmIsVisible()
        }
        
        return true;
    }
    
    private func markLoadingFinished() {
        adObject = nil;
        completion = nil;
        bidRequester = nil;
    }
    
    private func handlePrebidResponse(response: PBMBidResponse) {
        var demandResult = PBMFetchDemandResult.demandNoBids
        
        if  let winningBid = response.winningBid {
            if PBMMoPubUtils.setUpAdObject(adObject,
                                           withConfigId: configID,
                                           targetingInfo: winningBid.targetingInfo ?? [:],
                                           extraObject: winningBid,
                                           forKey: PBMMoPubAdUnitBidKey) {
                demandResult = .ok
            } else {
                demandResult = .wrongArguments
            }
        } else {
            PBMLog.error("The winning bid is absent in response!")
        }
        
        completeWithResult(demandResult)
    }

    private func handlePrebidError(error: Error?) {
        completeWithResult(PBMError.demandResult(fromError: error))
    }
    
    private func completeWithResult(_ fetchDemandResult: PBMFetchDemandResult) {
        defer {
            markLoadingFinished()
        }
        
        guard let adObject = self .adObject,
              let completion = self.completion else {
            return
        }
        
        lastAdObject = adObject
        lastCompletion = completion
        
        autoRefreshManager?.setupRefreshTimer()
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
}
