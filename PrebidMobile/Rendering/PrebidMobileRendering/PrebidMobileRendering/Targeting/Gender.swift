//
//  Gender.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public enum Gender : Int {
    case unknown
    case male
    case female
    case other
}

enum GenderDescription : String {
    case unknown    = ""
    case male       = "M"
    case female     = "F"
    case other      = "O"
}


func GenderFromDescription(_ genderDescription: GenderDescription) -> Gender {
    switch genderDescription {
        case .unknown:   return .unknown
        case .male:      return .male
        case .female:    return .female
        case .other:     return .other
    }
}

func DescriptionOfGender(_ gender: Gender) -> GenderDescription {
    switch gender {
        case .unknown:   return .unknown
        case .male:      return .male
        case .female:    return .female
        case .other:     return .other
    }
}

