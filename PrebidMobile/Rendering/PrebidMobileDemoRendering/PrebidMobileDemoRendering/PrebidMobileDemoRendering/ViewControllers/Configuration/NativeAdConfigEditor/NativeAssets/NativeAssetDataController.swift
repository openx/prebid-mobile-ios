//
//  NativeAssetDataController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka

import PrebidMobileRendering

class NativeAssetDataController: BaseNativeAssetController<NativeAssetData> {
    override func buildForm() {
        super.buildForm()
        
//        requiredPropertiesSection
//            <<< makeRequiredEnumRow("dataType", keyPath: \.dataType, defVal: .sponsored)
        
        addOptionalInt("length", keyPath: \.length)
    }
}
