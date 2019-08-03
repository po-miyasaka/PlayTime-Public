//
//  NotificationService.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/04/05Thursday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import Foundation
import UserNotifications
import PlayTimeObject

protocol NotificationServiceProtocol {
    func set(quest: Quest, limitTime: TimeInterval)
    func cancel()
    func isUserAcceptNotification(shouldAuthorizeIfneed: Bool, handler: @escaping (Bool) -> Void)
}

class NotificationService: NotificationServiceProtocol {

    static var `default` = NotificationService()

    func set(quest: Quest, limitTime: TimeInterval) {
        cancel()
        let content = UNMutableNotificationContent()
        content.title = quest.title.truncate(limit: 8) + "returnBaseExpression".localized
        content.body     = "totalPlayTime".localized + " " + (quest.playTime() + limitTime).displayOnlyMinutesText()
        content.sound = UNNotificationSound.default
        var tmp = limitTime
        if limitTime <= 0 {
            tmp = 300
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: tmp, repeats: false)
        let request = UNNotificationRequest(identifier: "jp.po-miyasaka.PunlicPlayTime.finishQuest",
                                            content: content,
                                            trigger: trigger)
        // ローカル通知予約
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func isUserAcceptNotification(shouldAuthorizeIfneed: Bool = false, handler: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                handler(true)
            case .denied:
                handler(false)
            case .notDetermined:
                if shouldAuthorizeIfneed {
                    self?.authorize(handler: handler)
                }
            case .provisional:
                handler(true)
            }
        }

    }

    func authorize(handler: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            handler(error == nil && granted)
        }
    }

    func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
