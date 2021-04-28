//
//  PBMNativeAdMarkupImageTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeAdMarkupImageTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<PBMNativeAdMarkupImage>, Error)] = []
        
        let optionalImageProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkupImage>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Image value", dicKey: "url", keyPath: \.url),
            JSONDecoding.OptionalPropertyCheck(value: PBMImageAssetType.main,
                                               writer: { $0["type"] = NSNumber(value: $1.rawValue) },
                                               reader: { (image: PBMNativeAdMarkupImage) -> PBMImageAssetType? in
                                                if let rawType = image.imageType?.intValue {
                                                    return PBMImageAssetType(rawValue: rawType)
                                                } else {
                                                    return nil
                                                }
                                               }),
            JSONDecoding.OptionalPropertyCheck(value: 640, dicKey: "w", keyPath: \.width),
            JSONDecoding.OptionalPropertyCheck(value: 480, dicKey: "h", keyPath: \.height),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let imageTester = JSONDecoding.Tester(generator: PBMNativeAdMarkupImage.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalImageProperties)
        
        imageTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<PBMNativeAdMarkupImage> =
            Equality.Tester(template: PBMNativeAdMarkupImage(url: ""), checks: [
                Equality.Check(values: "some url", "other url", keyPath: \.url),
                Equality.Check(values: 320, 640, keyPath: \.width),
                Equality.Check(values: 240, 480, keyPath: \.height),
                Equality.Check(values: PBMImageAssetType.main, .icon) { $0.imageType = NSNumber(value: $1.rawValue) },
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}