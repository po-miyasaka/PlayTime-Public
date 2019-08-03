//
//  Error.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/02Tuesday.
//  Copyright © 2018 pennet. All rights reserved.
//

import Foundation

//enum E: Swift.Error {
//    case error(String)
//    case uidNone
//    case questNone
//    case displayError(String)
//}

enum SettingsError: Swift.Error {
    case userNotificationSetDuringActive
    case osDeniedNotification

    var display: (title: String, message: String) {
        switch self {
        case .userNotificationSetDuringActive:
            return (title: "cant change timer".localized, message: "")
        case .osDeniedNotification:
            return (title: "cant notification for setting title".localized, message: "cant notification for setting message".localized)
        }
    }
}
