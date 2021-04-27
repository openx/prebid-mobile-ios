
import AppTrackingTransparency
import UIKit
import XCTest
@testable import PrebidMobileRendering

class DeviceInfoParameterBuilderTest: XCTestCase {

    let initialDict = [String:String]()
    var deviceInfoParameterBuilder: DeviceInfoParameterBuilder!
    var bidRequest: PBMORTBBidRequest!

    override func setUp() {
        self.deviceInfoParameterBuilder = DeviceInfoParameterBuilder(deviceAccessManager: MockDeviceAccessManager(rootViewController: nil))
        self.bidRequest = PBMORTBBidRequest()
    }

    override func tearDown() {
        MockDeviceAccessManager.reset()
    }

    func testDeviceSize() {
        self.deviceInfoParameterBuilder.build(self.bidRequest)
        
        PBMAssertEq(self.bidRequest.device.w, 100)
        PBMAssertEq(self.bidRequest.device.h, 200)
    }

    func testAdTrackingEnabled() {
        MockDeviceAccessManager.mockAdvertisingTrackingEnabled = true
        if #available(iOS 14, *) {
            MockDeviceAccessManager.mockAppTrackingTransparencyStatus = .authorized
        }
        
        self.deviceInfoParameterBuilder.build(self.bidRequest)
        PBMAssertEq(self.bidRequest.device.lmt, 0)
        PBMAssertEq(self.bidRequest.device.ifa, MockDeviceAccessManager.mockAdvertisingIdentifier)
        XCTAssertNil(self.bidRequest.device.extAtts.ifv)
        
        if #available(iOS 14, *) {
            PBMAssertEq(self.bidRequest.device.extAtts.atts as? UInt, ATTrackingManager.AuthorizationStatus.authorized.rawValue)
        }
    }

    func testAdTrackingDisabled() {
        MockDeviceAccessManager.mockAdvertisingTrackingEnabled = false
        
        if #available(iOS 14, *) {
            MockDeviceAccessManager.mockAppTrackingTransparencyStatus = .notDetermined
        }
        
        self.deviceInfoParameterBuilder.build(self.bidRequest)

        PBMAssertEq(self.bidRequest.device.lmt, 1)
        PBMAssertEq(self.bidRequest.device.ifa, MockDeviceAccessManager.nullUUID)
        PBMAssertEq(self.bidRequest.device.extAtts.ifv, MockDeviceAccessManager.mockIdentifierForVendor)
        
        if #available(iOS 14, *) {
            PBMAssertEq(self.bidRequest.device.extAtts.atts as? UInt, ATTrackingManager.AuthorizationStatus.notDetermined.rawValue)
        }
    }

    func testDeviceDetails() {
        self.deviceInfoParameterBuilder.build(self.bidRequest)

        PBMAssertEq(self.bidRequest.device.make, "MockMake")
        PBMAssertEq(self.bidRequest.device.model, "MockModel")
        PBMAssertEq(self.bidRequest.device.os, "MockOS")
        PBMAssertEq(self.bidRequest.device.osv, "1.2.3")
        PBMAssertEq(self.bidRequest.device.language, "ml")
    }

    func testNilDeviceLanguage() {
        MockDeviceAccessManager.mockUserLanguageCode = nil
        self.deviceInfoParameterBuilder.build(self.bidRequest)

        XCTAssertNil(self.bidRequest.device.language)
    }
}