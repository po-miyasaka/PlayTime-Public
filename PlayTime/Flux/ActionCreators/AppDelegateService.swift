//
//  AppDelegateActionCreator.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import UserNotifications

protocol AppDelegateServiceInputs {
    func applicationDidFinishLaunching(application: UIApplication, launchOptions: [AnyHashable: Any]?)
    func applicationOpenUrl(application: UIApplication,
                            url: URL,
                            sourceApplication: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
    func applicationDidBecomeActive(_ application: UIApplication)
    func applicationWillTerminate()

}

protocol AppDelegateServiceType {
    var inputs: AppDelegateServiceInputs { get }
}

final class AppDelegateService: NSObject, AppDelegateServiceType {
    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    init(flux: FluxProtocol = Flux.default, notificationService: NotificationServiceProtocol = NotificationService.default) {
        self.flux = flux
        self.notificationService = notificationService
    }

    var notificationService: NotificationServiceProtocol
    var inputs: AppDelegateServiceInputs { return self }
}

extension AppDelegateService: AppDelegateServiceInputs {
    func applicationWillTerminate() {
        flux.actionCreator.add(status: .launched)
    }

    func applicationDidFinishLaunching(application: UIApplication, launchOptions: [AnyHashable: Any]?) {
        if !flux.settingsStore.userStatus.contains(.shouldSaveDefaultStories) {
            flux.actionCreator.add(status: .shouldSaveDefaultStories)
            setDefaultStories()
        }
    }

    func applicationOpenUrl(application: UIApplication,
                            url: URL,
                            sourceApplication: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        flux.actionCreator.didBecomeActive()
        refreshUserNotification()
    }

    private func refreshUserNotification() {
        notificationService.isUserAcceptNotification(shouldAuthorizeIfneed: false) {[weak self] in
            self?.flux.actionCreator.osNotificationSet(isOn: $0)
        }
    }

    private func setDefaultStories() {
        let sema = DispatchSemaphore(value: 0)
        let defaultStoryNames = ["study".localized,
                                 "sports".localized,
                                 "hobby".localized]
        defaultStoryNames.forEach { storyName in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.flux.actionCreator.add(storyName: storyName)
                sema.signal()
            }
            sema.wait()
        }
    }
}
