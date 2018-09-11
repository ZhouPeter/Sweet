//
//  AppDelegate.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Mario Z. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import AVKit
import VolumeBar
import Contacts

var allowRotation = false

private let umengKey = "5b726bfeb27b0a4abd0000d8"
private let wechatKey = "wx819697effecdb6f5"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootController = UINavigationController(rootViewController: RootViewController())

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
        
        #if DEBUG
            window = DebugWindow(frame: UIScreen.main.bounds)
        #else
            window = UIWindow(frame: UIScreen.main.bounds)
        #endif
        
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()
        setupVolumeBar()
        
        WXApi.registerApp(wechatKey)
        UMConfigure.initWithAppkey(umengKey, channel: nil)
        
        registerUserNotificattion(launchOptions: launchOptions)
        let notification = launchOptions?[.remoteNotification] as? [String: AnyObject]
        let deepLink = DeepLinkOption.build(with: notification)
        applicationCoordinator.start(with: deepLink)
        getSetting()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        VersionUpdateHelper.versionCheck(viewController: rootController)
        NetworkHelper.networkCheck(viewController: rootController)
        addObservers()
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        logger.debug(userInfo)
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: WXApiManager.shared)
    }
    
}

// MARK: - Privates
extension AppDelegate {
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logoutAuth),
                                               name: NSNotification.Name(logoutNotiName),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contactStoreDidChange(_:)),
                                               name: NSNotification.Name.CNContactStoreDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showScreenShot(note:)),
                                               name: NSNotification.Name.UIApplicationUserDidTakeScreenshot,
                                               object: nil)
    }
    
    @objc func showScreenShot(note: Notification) {
        if let data = UIScreen.screenShot(), let image =  UIImage(data: data), let resultImage = image.addSlaveImage(slaveImage: #imageLiteral(resourceName: "ShareBottom")) {
            let controller = ScreenShotController(shotImage: resultImage)
            let newWindow = Share(frame: UIScreen.main.bounds)
            newWindow.windowLevel = UIWindowLevelStatusBar + 1
            newWindow.addSubview(controller.view)
            controller.view.frame = UIScreen.main.bounds
            newWindow.makeKeyAndVisible()
        }
    }
    @objc private func uploadContacts() {
        if web.tokenSource.token != nil {
            let contacts = Contacts.getContacts()
            web.request(.uploadContacts(contacts: contacts)) { (_) in }
        }
    }
    @objc private func contactStoreDidChange(_ notification: NSNotification) {
        uploadContacts()
    }
    
    private func getSetting() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        web.request(.getSetting(version: version!)) { (result) in
            switch result {
            case let .success(response):
                if let setting = response["setting"] as? [String: Any], let review = setting["review"] as? Int {
                    Defaults[.review] = review
                }
            case let .failure(error):
                logger.error(error)
                Defaults[.review] = 0
                
            }
        }
    }
    
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
    
    private func setupVolumeBar() {
        let volumeBar = VolumeBar.shared
        var style = VolumeBarStyle.likeInstagram
        style.height = 2
        style.cornerRadius = 1
        volumeBar.style = style
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
