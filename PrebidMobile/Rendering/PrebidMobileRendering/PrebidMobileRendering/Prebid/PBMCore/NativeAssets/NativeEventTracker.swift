//
//  NativeEventTracker.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeEventTracker : NSObject, NSCopying, PBMJsonCodable {
    
    /// [Required]
    /// Type of event available for tracking.
    @objc public let event: NativeEventType
    
    /// [Required]
    /// Array of the types of tracking available for the given event.
    /// See PBMNativeEventTrackingMethod
    @objc public let methods: [Int]
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
    @objc public var ext: [String : AnyHashable]?
    
    // MARK: - Private Properties
    
    @objc public init(event: NativeEventType, methods:[Int]) {
        self.event = event
        self.methods = methods
    }
    
    @objc public func setExt(_ ext: [String : AnyHashable]) throws {
        self.ext = try NSDictionary(dictionary: ext).unserializedCopy() as? [String : AnyHashable]
    }
    
    private override init()  {
        fatalError()
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let clone = NativeEventTracker(event: event, methods: methods)
        return clone
    }
    
    // MARK: - PBMJsonCodable
    
    public var jsonDictionary: [String : Any]? {
        var result = [String : Any]()
        result["event"] = event
        result["ext"] = ext
        result["methods"] = methods
        
        return result
    }
    
    public func toJsonString() throws -> String {
        try PBMFunctions.toStringJsonDictionary(jsonDictionary ?? [:])
    }
}
