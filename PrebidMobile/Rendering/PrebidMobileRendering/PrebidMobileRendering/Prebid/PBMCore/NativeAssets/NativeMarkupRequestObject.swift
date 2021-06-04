//
//  NativeMarkupRequestObject.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeMarkupRequestObject : NSObject, NSCopying, PBMJsonCodable {
    
    /// Version of the Native Markup version in use.
    public var version: String?

    /// [Recommended]
    /// [Integer]
    /// The context in which the ad appears.
    /// See PBMNativeContextType
    public var context: PBMNativeContextType?

    /// [Integer]
    /// A more detailed context in which the ad appears.
    /// See PBMNativeContextSubtype
    public var contextsubtype: PBMNativeContextSubtype?

    /// [Recommended]
    /// [Integer]
    /// The design/format/layout of the ad unit being offered.
    /// See PBMNativePlacementType
    public var plcmttype: PBMNativePlacementType?

    // NOT SUPPORTED:
    // /// [Integer]
    // /// The number of identical placements in this Layout. Refer Section 8.1 Multiplacement Bid Requests for further detail.
    var plcmtcnt: Int?

    /// [Integer]
    /// 0 for the first ad, 1 for the second ad, and so on.
    /// Note this would generally NOT be used in combination with plcmtcnt -
    /// either you are auctioning multiple identical placements (in which case plcmtcnt>1, seq=0)
    /// or you are holding separate auctions for distinct items in the feed (in which case plcmtcnt=1, seq=>=1)
    public var seq: Int?

    /// [Required]
    /// An array of Asset Objects. Any objects bid response must comply with the array of elements expressed in the bid request.
    public var assets: [NativeAsset]

    // NOT SUPPORTED:
    // /// [Integer]
    // /// Whether the supply source / impression supports returning an assetsurl instead of an asset object. 0 or the absence of the field indicates no such support.
    public var aurlsupport: Int?

    // NOT SUPPORTED:
    // /// [Integer]
    // /// Whether the supply source / impression supports returning a dco url instead of an asset object. 0 or the absence of the field indicates no such support.
    // /// Beta feature.
    public var durlsupport: Int?

    /// Specifies what type of event objects tracking is supported - see Event Trackers Request Object
    public var eventtrackers: [NativeEventTracker]?

    /// [Recommended]
    /// [Integer]
    /// Set to 1 when the native ad supports buyer-specific privacy notice. Set to 0 (or field absent) when the native ad doesn’t support custom privacy links or if support is unknown.
    public var privacy: Int?

    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
    @objc public var ext: [String : Any]?
    
    @objc public func setExt(_ ext: [String : Any]?) throws {
        guard let ext = ext else {
            self.ext = nil
            return
        }
        
        self.ext = try NSDictionary(dictionary: ext).unserializedCopy()
    }
    
    public init(assets: [NativeAsset]) {
        self.assets = assets
        version = "1.2"
    }

    // MARK: - Private Methods
    
    private override init() {
        fatalError()
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let clone = NativeMarkupRequestObject(assets: assets)
        
        clone.version = version
        clone.context = context
        clone.contextsubtype = contextsubtype
        clone.plcmttype = plcmttype
        clone.plcmtcnt = plcmtcnt
        clone.seq = seq
        clone.aurlsupport = aurlsupport
        clone.durlsupport = durlsupport
        clone.eventtrackers = eventtrackers
        clone.privacy = privacy
        clone.ext = ext
        
        return clone;
    }
    
    // MARK: - PBMJsonCodable
    
    public var jsonDictionary: [String : Any]? {
        var json = [String : Any]()
        
        json["ver"]             = version
        json["context"]         = context?.rawValue
        json["contextsubtype"]  = contextsubtype?.rawValue
        json["plcmttype"]       = plcmttype?.rawValue
        json["seq"]             = seq
        json["assets"]          = jsonAssets
        json["plcmtcnt"]        = plcmtcnt
        json["aurlsupport"]     = aurlsupport
        json["durlsupport"]     = durlsupport
        json["eventtrackers"]   = jsonTrackers
        json["privacy"]         = privacy
        json["ext"]             = ext
        
        return json;
    }
    
    public func toJsonString() throws -> String {
        try PBMFunctions.toStringJsonDictionary(jsonDictionary ?? [:])
    }
    
    // MARK: - Private  Methods
    
    func jsonAssets() -> [[String : Any]] {
        assets.compactMap { $0.jsonDictionary }
    }

    func jsonTrackers() -> [[String : Any]]? {
        eventtrackers?.compactMap { $0.jsonDictionary };
    }
}