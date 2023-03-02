//
//  AppDelegate.swift
//  FlashVPN
//
//  Created by Алексей Трушковский on 12.08.2021.
//

import OneSignal
import Firebase
import Amplitude

import MyTrackerSDK
import Branch

var remoteConfig = RemoteConfig.remoteConfig()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        MRMyTracker.trackerConfig()
        MRMyTracker.setAttributionDelegate(self)
        MRMyTracker.setupTracker("28149136463583291594")
        
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // do stuff with deep link data (nav to page, display content, etc)
            guard let attribution = params as? [String: AnyObject] else { return }
//            print("test deeplink: \(attribution)")
            guard let camp = attribution["~campaign"] else { return }
            Analytics.setUserProperty("\(camp)", forName: "userName")
        }
        
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey("c5f09b863a346c018c34b5c584e75ae2")
        Amplitude.instance().setUserId("userId")
        Amplitude.instance().logEvent("app_start")
        
        FirebaseApp.configure()
        
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("19905e6b-c229-4d9d-91d0-8d1a01fd8451")
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
        application.registerForRemoteNotifications()
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        Branch.getInstance().application(app, open: url, options: options)
      return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // handler for Push Notifications
      Branch.getInstance().handlePushNotification(userInfo)
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      // handler for Universal Links
      Branch.getInstance().continue(userActivity)
      return true
    }

}

extension AppDelegate: MRMyTrackerAttributionDelegate {
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func didReceive(_ attribution: MRMyTrackerAttribution)
    {
        guard let deeplink = attribution.deeplink else { return }
        guard let camp = getQueryStringParameter(url: deeplink, param: "camp") else { return }
        Analytics.setUserProperty("\(camp)", forName: "userName")
    }
}
