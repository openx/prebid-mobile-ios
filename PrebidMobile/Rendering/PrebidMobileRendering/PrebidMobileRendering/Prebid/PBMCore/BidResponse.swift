//
//  BidResponse.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class PBMBidResponse: NSObject {
    
    @objc public private(set) var allBids: [PBMBid]?
    @objc public private(set) var winningBid: PBMBid?
    @objc public private(set) var targetingInfo: [String : String]?
    
    @objc public var tmaxrequest: NSNumber? {
        //TODO use a separate var for storing this value instead of rawResponse
        rawResponse?.ext.tmaxrequest;
    }
    
    //TODO: do we need this??
    private(set) var rawResponse: RawBidResponse<PBMORTBBidResponseExt, NSDictionary, PBMORTBBidExt>?

    @objc public convenience init(jsonDictionary: JsonDictionary) {
        let rawResponse = PBMORTBBidResponse<PBMORTBBidResponseExt, NSDictionary, PBMORTBBidExt>(
            jsonDictionary: jsonDictionary as! [String : Any],
            extParser: { extDic in
                return PBMORTBBidResponseExt(jsonDictionary: extDic)
            },
            seatBidExtParser: { extDic in
                return extDic as NSDictionary
            },
            bidExtParser: { extDic in
                return PBMORTBBidExt(jsonDictionary: extDic)
            })

        self.init(rawBidResponse: rawResponse)
    }
    
    //TODO: make it visible only for test extensions
    //use rawResponse?.toJsonString() to convert JSON and init(jsonDictionary:)
    public required init(rawBidResponse: RawBidResponse<PBMORTBBidResponseExt, NSDictionary, PBMORTBBidExt>?) {

        rawResponse = rawBidResponse
        
        guard let rawBidResponse = rawBidResponse else {
            return
        }

        var allBids: [PBMBid] = []
        var targetingInfo: [String : String] = [:]
        var winningBid: PBMBid? = nil

        if let seatbid = rawBidResponse.seatbid {
            for nextSeatBid in seatbid {
                for nextBid in nextSeatBid.bid {
                    if let bid = PBMBid(bid: nextBid) {
                        allBids.append(bid)
                        
                        if winningBid == nil && bid.price > 0 && bid.isWinning {
                            winningBid = bid
                        } else if let bidTargetingInfo = bid.targetingInfo {
                            targetingInfo.merge(bidTargetingInfo) { $1 }
                        }
                    }
                }
            }
        }

        if let winningBidTargetingInfo = winningBid?.targetingInfo {
            targetingInfo.merge(winningBidTargetingInfo) { $1 }
        }

        self.winningBid = winningBid
        self.allBids = allBids
        self.targetingInfo = targetingInfo.count > 0 ? targetingInfo : nil
    }
 
}
