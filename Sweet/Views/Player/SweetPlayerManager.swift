//
//  BMPlayerManager.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import UIKit
import VIMediaCache
import AVFoundation
import NVActivityIndicatorView

public let sweetPlayerConf = SweetPlayerManager.shared

public enum SweetPlayerTopBarShowCase: Int {
    case always         = 0 /// 始终显示
    case horizantalOnly = 1 /// 只在横屏界面显示
    case none           = 2 /// 不显示
}

open class SweetPlayerManager {
    /// 单例
    static let shared = SweetPlayerManager()
    /// tint color
    var tintColor   = UIColor.white
    /// Loader
    var loaderType  = NVActivityIndicatorType.ballRotateChase
    /// should auto play
    var shouldAutoPlay = true
    var topBarShowInCase = SweetPlayerTopBarShowCase.always
    var animateDelayTimeInterval = TimeInterval(5)
    /// should show log
    var allowLog  = false
    /// use gestures to set brightness, volume and play position
    var enableBrightnessGestures = true
    var enableVolumeGestures = true
    var enablePlaytimeGestures = true
    var enableChooseDefinition = true
    var cacheManeger = VIResourceLoaderManager()
    internal static func asset(for resouce: SweetPlayerResourceDefinition) -> AVURLAsset {
        let asset = SweetPlayerManager.shared.cacheManeger.playerItem(with: resouce.url)
        return (asset!.asset as? AVURLAsset)!
    }
    /**
     打印log
     
     - parameter info: log信息
     */
    func log(_ info: String) {
        if allowLog {
            print(info)
        }
    }
}
