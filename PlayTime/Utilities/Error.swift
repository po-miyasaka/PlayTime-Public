//
//  Error.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/02Tuesday.
//  Copyright © 2018 pennet. All rights reserved.
//

import Foundation

enum E: Swift.Error {
    case error(String)
    case uidNone
    case questNone
    case displayError(String)
}

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

enum BackupError: Swift.Error {
    case localData
    case hostData
    case accurateDate
    case UID
    case hostedLessThanLocalForRestore
    case hostedMoreThanLocalForBackup
    case network
    case status
    case notLogined
    case logoutNow

    var display: (title: String, message: String) {
        switch self {
        case .localData:
            return (title: "dataNothing".localized, message: "")
        case .hostData:
            return (title: "noBackupData".localized, message: "")
        case .accurateDate:
            return (title: "noAccurateTime".localized, message: "")
        case .UID:
            return (title: "pleaseRetryToLogin".localized, message: "")
        case .hostedLessThanLocalForRestore:
            return (title: "cantRestoreLessData".localized, message: "")
        case .hostedMoreThanLocalForBackup:
            return (title: "cantBackupLargerData".localized, message: "")
        case .network:
            return (title: "pleaseRetryAfterMinites".localized, message: "")
        case .status:
            return (title: "pleaseRetryAfterMinites".localized, message: "")
        case .notLogined:
            return (title: "pleaseRetryToLogin".localized, message: "")
        case .logoutNow:
            return (title: "logouted".localized, message: "") // Fixme
        }
    }
}
