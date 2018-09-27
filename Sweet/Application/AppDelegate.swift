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
import Photos
import TencentOpenAPI

var allowRotation = false

private let umengKey = "5b726bfeb27b0a4abd0000d8"
private let wechatKey = "wx819697effecdb6f5"
private let tencentKey = "1106459659"
private let weiboKey = "3363635970"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootController = UINavigationController(rootViewController: RootViewController())
    private lazy var applicationCoordinator: Coordinator = self.makeCoordinator()

    // MARK: - UIApplicationDelegate
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupThirdPartySDKs()
        
        #if DEBUG
            window = DebugWindow(frame: UIScreen.main.bounds)
        #else
            window = UIWindow(frame: UIScreen.main.bounds)
        #endif
        
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()
        setupVolumeBar()
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
                                   "type": UpdateUserType.pushToken.rawValue])) { _ in }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString.hasPrefix("wx") {
            return WXApi.handleOpen(url, delegate: WXApiManager.shared)
        } else if  url.absoluteString.hasPrefix("tencent") {
            return TencentOAuth.handleOpen(url)
        } else if url.absoluteString.hasPrefix("wb") {
            return WeiboSDK.handleOpen(url, delegate: self)
        } else {
            return true
        }
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.absoluteString.hasPrefix("wx") {
            return WXApi.handleOpen(url, delegate: WXApiManager.shared)
        } else if  url.absoluteString.hasPrefix("tencent") {
            return TencentOAuth.handleOpen(url)
        } else if url.absoluteString.hasPrefix("wb") {
            return WeiboSDK.handleOpen(url, delegate: self)
        } else {
            return true
        }
    }
    
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if allowRotation {
            return [.portrait, .landscapeRight, .landscapeLeft]
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
}

extension AppDelegate: WeiboSDKDelegate {
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {}
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {}
}

// MARK: - Privates

extension AppDelegate {
    private func setupThirdPartySDKs() {
        WXApi.registerApp(wechatKey)
        _ = TencentOAuth.init(appId: tencentKey, andDelegate: nil)
        UMConfigure.initWithAppkey(umengKey, channel: nil)
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(weiboKey)
    }
    
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
        logger.debug(note)
        getScreenShotInAlbum { (image) in
            let screenshot = image ?? UIScreen.screenshot()
            guard let newImage = screenshot?.addedFooterImage(#imageLiteral(resourceName: "ShareBottom")) else {
                logger.verbose("screenshot is nil")
                return
            }
            let controller = ScreenShotController(shotImage: newImage)
            let newWindow = Share(frame: UIScreen.main.bounds)
            newWindow.rootViewController = controller
            newWindow.windowLevel = UIWindowLevelStatusBar + 1
            newWindow.makeKeyAndVisible()
        }
    }
    
    private func getScreenShotInAlbum(callback: @escaping (UIImage?) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            callback(nil)
            return
        }
        let now = Date()
        let delay: TimeInterval = UIDevice.current.hasLessThan2GBRAM ? 2 : 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            var asset: PHAsset?
            PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
                .enumerateObjects { (collection, _, shouldStop) in
                    guard asset == nil else { return }
                    let title = collection.localizedTitle ?? ""
                    guard title == "Screenshots" || title == "屏幕快照" else { return }
                    shouldStop.pointee = true
                    let options = PHFetchOptions()
                    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let results = PHAsset.fetchAssets(in: collection, options: options)
                    guard results.count > 0 else { return }
                    asset = results.object(at: 0)
            }
            guard let targetAsset = asset, let date = targetAsset.creationDate, abs(date.timeIntervalSince(now)) < 3 else {
                DispatchQueue.main.async { callback(nil) }
                return
            }
            AssetManager.resolveAsset(targetAsset,
                                      size: UIScreen.main.bounds.size,
                                      completion: { image in DispatchQueue.main.async { callback(image) } })
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
