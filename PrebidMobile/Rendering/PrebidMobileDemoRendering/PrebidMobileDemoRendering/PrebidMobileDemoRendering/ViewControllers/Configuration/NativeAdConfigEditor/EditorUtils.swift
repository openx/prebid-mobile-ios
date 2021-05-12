//
//  EditorUtils.swift
//  PrebidMobileDemoRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

class EditorUtils{
    class func assetName(_ obj: NativeAsset) -> String {
        return String(String(describing: type(of: obj)).dropFirst("NativeAsset".count)).lowercased()
    }
}
