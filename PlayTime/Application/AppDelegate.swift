//
//  AppDelegate.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/01/01Monday.
//  Copyright © 2018 pennet. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift

import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let appDelegateService = AppDelegateService()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { // swiftlint:disable:this discouraged_optional_collection

        appDelegateService.inputs.applicationDidFinishLaunching(application: application, launchOptions: launchOptions)
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return appDelegateService.inputs.applicationOpenUrl(application: app, url: url, sourceApplication: options)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appDelegateService.inputs.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        appDelegateService.inputs.applicationWillTerminate()
    }

}
