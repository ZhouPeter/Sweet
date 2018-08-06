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
    var clickCallBack: ((Int) -> Void)?
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
        label.tag = 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(showWebView(_:)))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var complainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor.xpTextGray()
        label.text = "《侵权投诉指引》"
        label.tag = 2
        let tap = UITapGestureRecognizer(target: self, action: #selector(showWebView(_:)))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
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
        if let tapView = tap.view {
            clickCallBack?(tapView.tag)
        }
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
        messageLabel.centerX(to: self, offset: -70)
        messageLabel.align(.top, to: roundedTopView, inset: 10)
        addSubview(complainLabel)
        complainLabel.centerX(to: self, offset: 70)
        complainLabel.align(.top, to: roundedTopView, inset: 10)
        addSubview(countryLabel)
        countryLabel.centerX(to: self)
        countryLabel.align(.bottom, to: self, inset: 10)
    }
    
}

protocol AboutView: BaseView {
    var showWebView: ((String, String) -> Void)? { get set }
    var showUpdate: ((UserResponse, UpdateRemainResponse) -> Void)? { get set }
    var showFeedback: (() -> Void)? { get set }

}
class AboutController: BaseViewController, AboutView {
    
    var showUpdate: ((UserResponse, UpdateRemainResponse) -> Void)?
    
    var showFeedback: (() -> Void)?
    
    var showWebView: ((String, String) -> Void)?
    
    private var user: UserResponse
    private var updateRemain: UpdateRemainResponse
    init(user: UserResponse, updateRemain: UpdateRemainResponse) {
        self.user = user
        self.updateRemain = updateRemain
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
            self.showUpdate?(self.user, self.updateRemain)
        }
        let questionRectView = AboutRectView(title: "常见问题")
        view.addSubview(questionRectView)
        questionRectView.equal(.size, to: updateRectView)
        questionRectView.centerX(to: updateRectView)
        questionRectView.pin(.bottom, to: updateRectView, spacing: 20)
        questionRectView.clickCallBack = { [weak self] in
            let title = "常见问题"
            let urlString = "http://mx.miaobo.me/faq.html"
            self?.showWebView?(title, urlString)
        }
        let feedbackRectView = AboutRectView(title: "用户反馈")
        view.addSubview(feedbackRectView)
        feedbackRectView.equal(.size, to: updateRectView)
        feedbackRectView.centerX(to: updateRectView)
        feedbackRectView.pin(.bottom, to: questionRectView, spacing: 20)
        feedbackRectView.clickCallBack = { [weak self] in
            self?.showFeedback?()
        }
        let logoutRectView = AboutRectView(title: "退出登录")
        view.addSubview(logoutRectView)
        logoutRectView.equal(.size, to: updateRectView)
        logoutRectView.centerX(to: updateRectView)
        logoutRectView.pin(.bottom, to: feedbackRectView, spacing: 20)
        logoutRectView.clickCallBack = { [weak self] in
            self?.showLogoutAlert()
        }
        
        let bottomView = AboutBottomView()
        bottomView.clickCallBack = { tag in
            let url: URL
            if tag == 1 {
                url = URL(string: "http://mx.miaobo.me/privacy.html")!
            } else {
                url = URL(string: "https://www.baidu.com")!
            }
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
        let controller = UIAlertController()
        let doneAction = UIAlertAction.makeAlertAction(title: "退出登录", style: .default) { (_) in
            web.request(.logout, completion: { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .success:
                    WebProvider.logout()
                case let .failure(error):
                    logger.error(error)
                    self.toast(message: "登出失败")
                }
            })
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(doneAction)
        controller.addAction(cancelAction)
       self.present(controller, animated: true, completion: nil)
    }
}
