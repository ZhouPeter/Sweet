//
//  TLStoryAuthorizationController.swift
//  TLStoryCamera
//
//  Created by 郭锐 on 2017/5/26.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit

protocol TLStoryAuthorizedDelegate: NSObjectProtocol {
    func requestCameraAuthorizeSuccess()
    func requestMicAuthorizeSuccess()
    func requestAllAuthorizeSuccess()
}

class TLStoryAuthorizationController: UIViewController {
    public weak var delegate: TLStoryAuthorizedDelegate?
    
    fileprivate var bgBlurView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .dark))
    
    fileprivate var titleLabel: UILabel = {
        let lable = UILabel()
        lable.text = "允许访问即可拍摄照片和视频"
        lable.textColor = UIColor(hex: 0xcccccc)
        lable.font = UIFont.systemFont(ofSize: 18)
        return lable
    }()
    
    fileprivate var cameraButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("启用相机访问权限", for: .normal)
        btn.setTitle("相机访问权限已启用", for: .selected)
        btn.setTitleColor(UIColor(hex: 0x4797e1), for: .normal)
        btn.setTitleColor(UIColor(hex: 0x999999), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var micButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("启用麦克风访问权限", for: .normal)
        btn.setTitle("麦克风访问权限已启用", for: .selected)
        btn.setTitleColor(UIColor(hex: 0x4797e1), for: .normal)
        btn.setTitleColor(UIColor(hex: 0x999999), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var authorizedManager = TLAuthorizedManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(bgBlurView)
        bgBlurView.frame = self.view.bounds
        
        self.view.addSubview(titleLabel)
        titleLabel.sizeToFit()
        let halfWidth = self.view.bounds.midX
        let halfHeight = self.view.bounds.midY
        titleLabel.center = CGPoint(x: halfWidth, y: halfHeight - 45 - titleLabel.bounds.midY)
        
        cameraButton.isSelected = TLAuthorizedManager.checkAuthorization(with: .camera)
        micButton.isSelected = TLAuthorizedManager.checkAuthorization(with: .mic)
        
        self.view.addSubview(cameraButton)
        cameraButton.sizeToFit()
        cameraButton.center = CGPoint.init(x: halfWidth, y: halfHeight + 20 + cameraButton.bounds.midY)
        
        self.view.addSubview(micButton)
        micButton.sizeToFit()
        micButton.center = CGPoint.init(x: halfWidth, y: cameraButton.frame.maxY + 30 + micButton.bounds.midY)
        
        cameraButton.addTarget(self, action: #selector(didPressCameraButton), for: .touchUpInside)
        self.micButton.addTarget(self, action: #selector(didPressMicButton), for: .touchUpInside)
    }
    
    @objc fileprivate func didPressCameraButton() {
        TLAuthorizedManager.requestAuthorization(with: .camera) { (_, success) in
            if !success {
                return
            }
            self.cameraButton.isEnabled = true
            self.cameraButton.isSelected = true
            self.cameraButton.sizeToFit()
            var center = self.cameraButton.center
            center.x  = self.view.bounds.midX
            self.cameraButton.center = center
            self.delegate?.requestCameraAuthorizeSuccess()
            self.dismiss()
        }
    }
    
    @objc fileprivate func didPressMicButton() {
        TLAuthorizedManager.requestAuthorization(with: .mic) { (_, success) in
            if !success {
                return
            }
            self.micButton.isEnabled = true
            self.micButton.isSelected = true
            self.micButton.sizeToFit()
            var center = self.micButton.center
            center.x  = self.view.bounds.midX
            self.micButton.center = center
            self.delegate?.requestMicAuthorizeSuccess()
            self.dismiss()
        }
    }
    
    fileprivate func dismiss() {
        if TLAuthorizedManager.checkAuthorization(with: .camera) && TLAuthorizedManager.checkAuthorization(with: .mic) {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.alpha = 0
            }, completion: { _ in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                self.delegate?.requestAllAuthorizeSuccess()
            })
        }
    }
}
