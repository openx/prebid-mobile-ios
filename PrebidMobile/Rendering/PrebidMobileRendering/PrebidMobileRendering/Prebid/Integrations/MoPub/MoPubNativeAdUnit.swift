//
//  MoPubNativeAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class MoPubNativeAdUnit : NSObject {
    
    weak var adObject: NSObject?
    var completion: ((PBMFetchDemandResult) -> Void)?
    var nativeAdUnit: PBMNativeAdUnit
    
    // MARK: - Public Properties
    
    var configID: String {
        nativeAdUnit.configId
    }
    
    var nativeAdConfiguration: PBMNativeAdConfiguration {
        nativeAdUnit.nativeAdConfig
    }
    
    // MARK: - Public Methods
    
    public init(configID: String,
                nativeAdConfiguration: PBMNativeAdConfiguration) {
        
        nativeAdUnit = PBMNativeAdUnit(configID: configID,
                                       nativeAdConfiguration: nativeAdConfiguration)
    }
    
    public func fetchDemand(with adObject: NSObject,
                            completion: ((PBMFetchDemandResult)->Void)?) {
        
        if !PBMMoPubUtils.isCorrectAdObject(adObject) {
            completion?(.wrongArguments)
            return
        }
        
        self.completion = completion
        self.adObject = adObject
        
        if let moPubObject = self.adObject as? PBMMoPubAdObjectProtocol {
            PBMMoPubUtils.cleanUpAdObject(moPubObject)
        }
        
        nativeAdUnit.fetchDemand { [weak self] fetchDemandInfo in
            guard let self = self else {
                return
            }
            
            if fetchDemandInfo.fetchDemandResult != .ok {
                self.completeWithResult(fetchDemandInfo.fetchDemandResult)
                return
            }
            
            var fetchDemandResult: PBMFetchDemandResult = .wrongArguments
            
            if PBMMoPubUtils.setUpAdObject(self.adObject,
                                           withConfigId: self.configID,
                                           targetingInfo: fetchDemandInfo.bid?.targetingInfo ?? [:],
                                           extraObject: fetchDemandInfo,
                                           forKey: PBMMoPubAdNativeResponseKey) {
                fetchDemandResult = .ok
            }
            
            self.completeWithResult(fetchDemandResult)
        }
    }
    
    // MARK: - Context Data

    public func addContextData(_ data: String, forKey key: String) {
        nativeAdUnit.addContextData(data, forKey: key)
    }
    
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        nativeAdUnit.updateContextData(data, forKey: key)
    }
    
    public func removeContextDate(forKey key: String) {
        nativeAdUnit.removeContextData(forKey: key)
    }
    
    public func clearContextData() {
        nativeAdUnit.clearContextData()
    }
    
    // MARK: - Private Methods
    
    private func completeWithResult(_ fetchDemandResult: PBMFetchDemandResult) {
        guard let completion = self.completion else {
            return
        }
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
    
}
