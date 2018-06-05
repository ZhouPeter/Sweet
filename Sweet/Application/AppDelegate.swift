//
//  AppDelegate.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Mario Z. All rights reserved.
//

import UIKit

var allowRotation = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootController = UINavigationController()

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if allowRotation {
            return [.portrait, .landscapeRight, .landscapeLeft]
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    private lazy var applicationCoordinator: Coordinator = self.makeCoordinator()

    // MARK: - UIApplicationDelegate
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()
        registerUserNotificattion(launchOptions: launchOptions)
        let notification = launchOptions?[.remoteNotification] as? [String: AnyObject]
        let deepLink = DeepLinkOption.build(with: notification)
        applicationCoordinator.start(with: deepLink)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logoutAuth),
                                               name: NSNotification.Name(logoutNotiName),
                                               object: nil)
        WXApi.registerApp("wx819697effecdb6f5")
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UMessage.registerDeviceToken(deviceToken)
        let device = NSData(data: deviceToken)
        let deviceTokenString: String = device.description
                                           .replacingOccurrences(of: "<", with: "")
                                           .replacingOccurrences(of: ">", with: "")
                                           .replacingOccurrences(of: " ", with: "")
        if web.tokenSource.token != nil {
            web.request(
               .update(
                updateParameters: ["pushCode": deviceTokenString,
                                   "pushDeviceType": 1,
                                   "type": UpdateUserType.pushToken.rawValue])) { (result) in
                switch result {
                case .success:
                    logger.debug("上传deviceToken成功")
                case let .failure(error):
                    logger.error(error)
                    logger.debug("上传deviceToken失败")
                }
            }
        }
        logger.debug(deviceTokenString)
    }
    
}

// MARK: - Privates
extension AppDelegate {
    
    @objc func logoutAuth(notification: Notification) {
        if let coordinator = applicationCoordinator as? ApplicationCoordinator {
            coordinator.removeAllDependency()
            applicationCoordinator.start(with: .signUp)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return ApplicationCoordinator(
            router: RouterImp(rootController: rootController),
            coordinatorFactory: CoordinatorFactoryImp()
        )
    }
    
    private func registerUserNotificattion(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard let types = UIApplication.shared.currentUserNotificationSettings?.types else { return }
        UMConfigure.initWithAppkey("5a093ce9b27b0a6bc500017d", channel: nil)
        #if DEBUG
        UMConfigure.setLogEnabled(true)
        #endif
        if types != [] {
            UMessage.registerForRemoteNotifications(launchOptions: launchOptions,
                                                    entity: nil,
                                                    completionHandler: {(_, _) in })
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.delegate = self
            }
        }
    }
    
    func setUserNotificationCenter(completion: (() -> Void)?) {
        UMessage.registerForRemoteNotifications(launchOptions: nil,
                                                entity: nil,
                                                completionHandler: {(_, _) in })
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            let types: UNAuthorizationOptions = [.badge, .alert, .sound]
            center.requestAuthorization(options: types) { (_, _) in
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    private func showControllerWithMessge(userInfo: [AnyHashable: Any]) {
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
             @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger {
            UMessage.setAutoAlert(false)
            UMessage.didReceiveRemoteNotification(userInfo)
        }
        completionHandler([.sound, .badge, .alert])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            showControllerWithMessge(userInfo: userInfo)
            UMessage.didReceiveRemoteNotification(userInfo)
        }
    }

}
