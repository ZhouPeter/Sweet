//
//  ScreenShotController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
class ScreenShotController: UIViewController {

    private lazy var shareView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "分享到"
        label.textColor = UIColor(hex: 0x4A4A4A)
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var conversationButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Conversation"), for: .normal)
        button.setTitle("微信", for: .normal)
        button.setTitleColor(UIColor(hex: 0x4A4A4A), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tag = 0
        button.addTarget(self, action: #selector(shareToWeChat(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var timelineButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Timeline"), for: .normal)
        button.setTitle("朋友圈", for: .normal)
        button.setTitleColor(UIColor(hex: 0x4A4A4A), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tag = 1
        button.addTarget(self, action: #selector(shareToWeChat(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var shotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let shotImage: UIImage
    init(shotImage: UIImage) {
        self.shotImage = shotImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        setupUI()
        shotImageView.image = shotImage
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressView(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didPressView(_ sender: UITapGestureRecognizer) {
        if let window = view.window as? Share {
           window.dismiss()
        }
        view.removeFromSuperview()
    }

    @objc private func shareToWeChat(_ sender: UIButton) {
        if sender.tag == 0 {
            WXApi.sendImage(image: shotImage, scene: .conversation)
        } else {
            WXApi.sendImage(image: shotImage, scene: .timeline)
        }
    }
    private func setupUI() {
        view.addSubview(shareView)
        shareView.align(.left)
        shareView.align(.right)
        shareView.align(.bottom)
        shareView.constrain(height: 160)
        shareView.addSubview(titleLabel)
        titleLabel.centerX(to: shareView)
        titleLabel.align(.top, inset: 10)
        shareView.addSubview(conversationButton)
        conversationButton.align(.top, inset: 50)
        conversationButton.centerX(to: shareView, offset: -75)
        conversationButton.constrain(width: 50, height: 70)
        conversationButton.setImageTop(space: 5)
        shareView.addSubview(timelineButton)
        timelineButton.centerY(to: conversationButton)
        timelineButton.centerX(to: shareView, offset: 75)
        timelineButton.constrain(width: 50, height: 70)
        timelineButton.setImageTop(space: 5)
        view.addSubview(shotImageView)
        shotImageView.align(.top, inset: 15 + UIScreen.safeTopMargin())
        shotImageView.pin(.top, to: shareView, spacing: 15)
        shotImageView.centerX(to: view)
        shotImageView.widthAnchor.constraint(equalTo: shotImageView.heightAnchor, multiplier: shotImage.size.width / shotImage.size.height).isActive = true
        
    }
}
