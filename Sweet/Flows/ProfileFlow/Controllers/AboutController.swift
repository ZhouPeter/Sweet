//
//  AboutController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class RoundedTopView: UIView {
    var cornerRadius: CGFloat
    var fillColor: UIColor
    private var roundedLayer: CAShapeLayer
    
    override init(frame: CGRect) {
        cornerRadius = 0
        fillColor = .white
        roundedLayer = CAShapeLayer()
        super.init(frame: frame)
        layer.insertSublayer(roundedLayer, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let roundedBezier = UIBezierPath(roundedRect: bounds,
                                         byRoundingCorners: [.topLeft, .topRight],
                                         cornerRadii: CGSize(width: cornerRadius,
                                                             height: cornerRadius))
        roundedLayer.path = roundedBezier.cgPath
        roundedLayer.fillColor = fillColor.cgColor
    }

}

class AboutBottomView: UIView {
    var clickCallBack: (() -> Void)?
    private lazy var roundedTopView: RoundedTopView = {
        let view = RoundedTopView()
        view.fillColor = .white
        view.cornerRadius = 8
        return view
    }()
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.xpTextGray()
        let info = Bundle.main.infoDictionary
        let version = info!["CFBundleShortVersionString"]!
        label.text = "v\(version)"
        return label
    }()
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor.xpTextGray()
        label.text = "《讲真用户协议》"
        return label
    }()
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "© 2018 杭州秒赞科技有限公司"
        label.textColor = UIColor.xpTextGray()
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showWebView(_ tap: UITapGestureRecognizer) {
        clickCallBack?()
    }
    
    private func setupUI() {
        addSubview(versionLabel)
        versionLabel.centerX(to: self)
        versionLabel.align(.top, to: self)
        addSubview(roundedTopView)
        roundedTopView.constrain(height: 62)
        roundedTopView.align(.left, to: self)
        roundedTopView.align(.right, to: self)
        roundedTopView.align(.bottom, to: self)
        addSubview(messageLabel)
        messageLabel.centerX(to: self)
        messageLabel.align(.top, to: roundedTopView, inset: 10)
        addSubview(countryLabel)
        countryLabel.centerX(to: self)
        countryLabel.align(.bottom, to: self, inset: 10)
    }
    
}

protocol AboutView: BaseView {
    var showWebView: ((String, String) -> Void)? { get set }
    var showUpdate: ((UserResponse) -> Void)? { get set }
    var showFeedback: (() -> Void)? { get set }

}
class AboutController: BaseViewController, AboutView {
    
    var showUpdate: ((UserResponse) -> Void)?
    
    var showFeedback: (() -> Void)?
    
    var showWebView: ((String, String) -> Void)?
    
    var user: UserResponse?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "更多"
        view.backgroundColor = UIColor.xpGray()
        setButtons()
    }
    
    // swiftlint:disable function_body_length
    private func setButtons() {
        let updateRectView = AboutRectView(title: "修改资料")
        view.addSubview(updateRectView)
        updateRectView.align(.left, to: view, inset: 30)
        updateRectView.align(.right, to: view, inset: 30)
        updateRectView.constrain(height: 50)
        updateRectView.align(.top, to: view, inset: UIScreen.navBarHeight() + 20)
        updateRectView.clickCallBack = { [weak self] in
            guard let `self` = self else { return }
            self.showUpdate?(self.user!)
        }
        let questionRectView = AboutRectView(title: "常见问题")
        view.addSubview(questionRectView)
        questionRectView.size(.width, to: updateRectView)
        questionRectView.size(.height, to: updateRectView)
        questionRectView.centerX(to: updateRectView)
        questionRectView.pin(to: updateRectView, edge: .bottom, spacing: -20)
        questionRectView.clickCallBack = { [weak self] in
            let title = "常见问题"
            let urlString = "http://mx.miaobo.me/faq.html"
            self?.showWebView?(title, urlString)
        }
        let feedbackRectView = AboutRectView(title: "意见反馈")
        view.addSubview(feedbackRectView)
        feedbackRectView.size(.width, to: updateRectView)
        feedbackRectView.size(.height, to: updateRectView)
        feedbackRectView.centerX(to: updateRectView)
        feedbackRectView.pin(to: questionRectView, edge: .bottom, spacing: -20)
        feedbackRectView.clickCallBack = { [weak self] in
            self?.showFeedback?()
        }
        let logoutRectView = AboutRectView(title: "退出登录")
        view.addSubview(logoutRectView)
        logoutRectView.size(.width, to: updateRectView)
        logoutRectView.size(.height, to: updateRectView)
        logoutRectView.centerX(to: updateRectView)
        logoutRectView.pin(to: feedbackRectView, edge: .bottom, spacing: -20)
        logoutRectView.clickCallBack = { [weak self] in
            self?.showLogoutAlert()
        }
        
        let bottomView = AboutBottomView()
        bottomView.clickCallBack = {
            let url = URL(string: "http://mx.miaobo.me/privacy.html")!
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        view.addSubview(bottomView)
        bottomView.align(.left, to: view, inset: 18)
        bottomView.align(.right, to: view, inset: 18)
        bottomView.align(.bottom, to: view)
        bottomView.constrain(height: 82)
        
    }
}

extension AboutController {
    func showLogoutAlert() {
        let controller = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        let doneAction = UIAlertAction(title: "退出登录", style: .default) { (_) in
            web.request(.logout, completion: { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .success:
                    WebProvider.logout()
                case let .failure(error):
                    logger.error(error)
                    self.toast(message: "登出失败", duration: 2)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        controller.addAction(doneAction)
        controller.addAction(cancelAction)
       self.present(controller, animated: true, completion: nil)
    }
}
