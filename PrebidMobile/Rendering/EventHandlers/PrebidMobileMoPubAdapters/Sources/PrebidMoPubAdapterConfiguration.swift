//
//  PrebidMoPubAdapterConfiguration.swift
//  PrebidMobileMoPubAdapters
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

import MoPubSDK

import PrebidMobileRendering

@objc(PrebidMoPubAdapterConfiguration)
public class PrebidMoPubAdapterConfiguration : MPBaseAdapterConfiguration {
    
    // MARK: - MPAdapterConfiguration
    
    public override var adapterVersion: String {
        "\(PBMSDKConfiguration.sdkVersion).\(Constants.adapterVersion)"
    }
    
    public override var networkSdkVersion: String {
        PBMSDKConfiguration.sdkVersion
    }
    
    // NOTE: absence of this property may lead to crash
    public override var moPubNetworkName: String {
        Constants.mopubNetworkName
    }
    
    public override var biddingToken: String? {
        nil
    }
    
    public override func initializeNetwork(withConfiguration configuration: [String : Any]?, complete: ((Error?) -> Void)? = nil) {
        PBMSDKConfiguration.initializeSDK()
        
        PBMSDKConfiguration.singleton.logLevel = .info
        PBMSDKConfiguration.singleton.locationUpdatesEnabled = true
        PBMSDKConfiguration.singleton.creativeFactoryTimeout = 15
        
        complete?(nil)
    }
 }