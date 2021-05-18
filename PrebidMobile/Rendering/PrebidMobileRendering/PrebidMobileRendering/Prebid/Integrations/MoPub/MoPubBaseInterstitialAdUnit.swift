//
//  MoPubBaseInterstitialAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

class MoPubBaseInterstitialAdUnit : NSObject {
    
    let adUnitConfig: PBMAdUnitConfig
    
    public var configId: String {
        adUnitConfig.configId
    }
    
    var bidRequester: PBMBidRequester?
    
    var adObject: NSObject?
    var completion: ((PBMFetchDemandResult) -> Void)?
    
    init(configId: String) {
        
        adUnitConfig = PBMAdUnitConfig(configId: configId)
        adUnitConfig.isInterstitial = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.videoPlacementType = .sliderOrFloating
    }
    
    public func fetchDemand(with adObject: NSObject,
                            completion: ((PBMFetchDemandResult)->Void)?) {
        
        fetchDemand(with: adObject,
                    connection: PBMServerConnection.singleton(),
                    sdkConfiguration: PBMSDKConfiguration.singleton,
                    targeting: PBMTargeting.shared(),
                    completion: completion)
    }
    
    // MARK: - Context Data

    public func addContextData(_ data: String, forKey key: String) {
        adUnitConfig.addContextData(data, forKey: key)
    }
    
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        adUnitConfig.updateContextData(data, forKey: key)
    }
    
    public func removeContextDate(forKey key: String) {
        adUnitConfig.removeContextData(forKey: key)
    }
    
    public func clearContextData() {
        adUnitConfig.clearContextData()
    }
    
    // MARK: - Internal Methods
    
    private func fetchDemand(with adObject: NSObject,
                             connection: PBMServerConnectionProtocol,
                             sdkConfiguration: PBMSDKConfiguration,
                             targeting: PBMTargeting,
                             completion: ((PBMFetchDemandResult)->Void)?) {
        guard bidRequester != nil else {
            // Request in progress
            return
        }
        
        if !PBMMoPubUtils.isCorrectAdObject(adObject) {
            completion?(.wrongArguments)
            return
        }
        
        self.adObject = adObject
        self.completion = completion
        
        if let moPubObject = self.adObject as? PBMMoPubAdObjectProtocol {
            PBMMoPubUtils.cleanUpAdObject(moPubObject)
        }
        
        bidRequester = PBMBidRequester(connection: connection,
                                       sdkConfiguration: sdkConfiguration,
                                       targeting: targeting,
                                       adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids(completion: { [weak self] (bidResponse, error) in
            if let response = bidResponse {
                self?.handleBidResponse(response)
            } else {
                self?.handleBidRequestError(error)
            }
        })
    }
    
    // MARK: - Private Methods
    
    private func handleBidResponse(_ bidResponse: PBMBidResponse) {
        var demandResult = PBMFetchDemandResult.demandNoBids
        
        if let winningBid = bidResponse.winningBid,
           let mopubObject = adObject as? PBMMoPubAdObjectProtocol,
           let targetingInfo = winningBid.targetingInfo {
            
            if PBMMoPubUtils.setUpAdObject(mopubObject,
                                           withConfigId: configId,
                                           targetingInfo: targetingInfo,
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
    
    private func handleBidRequestError(_ error: Error?) {
        completeWithResult(PBMError.demandResult(fromError: error))
    }
    
    private func completeWithResult(_ demandResult: PBMFetchDemandResult) {
        if let completion = self.completion {
            DispatchQueue.main.async {
                completion(demandResult)
            }
        }
        
        self.completion = nil
        
        markLoadingFinished()
    }
    
    private func markLoadingFinished() {
        
    }
}
