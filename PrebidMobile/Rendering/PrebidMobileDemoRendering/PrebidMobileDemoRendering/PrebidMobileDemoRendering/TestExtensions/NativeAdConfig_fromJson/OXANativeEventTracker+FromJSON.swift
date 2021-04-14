//
//  OXANativeEventTracker+FromJSON.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension OXANativeEventTracker {
    convenience init?(json: [String: Any]) {
        guard let rawEvent = json["event"] as? NSNumber,
              let event = OXANativeEventType(rawValue: rawEvent.intValue),
              let methods = json["methods"] as? [NSNumber]
        else {
            return nil
        }
        self.init(event: event, methods: methods)
        try? setExt(json["ext"] as? [String: Any])
    }
}