//
//  MainViewController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class AuthViewController: BaseViewController, AuthView {
    var showSignUp: ((LoginRequestBody) -> Void)?
    var showLogin: ((LoginRequestBody) -> Void)?
    
    var loginRequestBody = LoginRequestBody()
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(UIColor.xpTextGray(), for: .normal)
        button.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "Logo_icon")
        return imageView
    }()
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        setNoteLabelAttributedString(label: label)
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showUserWebView(_:)))
        label.addGestureRecognizer(tap)
        return label
    }()

    private lazy var registerButton: ShrinkButton = {
        let button = ShrinkButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("注册", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(registerAction(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setNoteLabelAttributedString(label: UILabel) {
        let string = "注册即表示同意《讲真用户协议》"
        let attributedString = NSMutableAttributedString(string: string)
        let headerLength = 7
        let headerDictionary = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),
                                    NSAttributedStringKey.foregroundColor: UIColor.xpTextGray()]
        let footerDictionary = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13),
                                NSAttributedStringKey.foregroundColor: UIColor.xpTextGray()]
        attributedString.setAttributes(headerDictionary,
                                       range: NSRange(location: 0, length: headerLength))
        attributedString.setAttributes(footerDictionary,
                                       range: NSRange(location: headerLength,
                                                      length: attributedString.length - headerLength))
        label.attributedText = attributedString
    }
    
    @objc private func showUserWebView(_ tap: UITapGestureRecognizer) {
        let url = URL(string: "http://mx.miaobo.me/privacy.html")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc private func loginAction(_ sender: UIButton) {
        loginRequestBody.register = false
        showLogin?(loginRequestBody)
    }
    
    @objc private func registerAction(_ sender: ShrinkButton) {
        loginRequestBody.register = true
        showSignUp?(loginRequestBody)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.xpYellow()
        view.addSubview(loginButton)
        loginButton.align(.right, to: view, inset: 16)
        loginButton.constrain(width: 60, height: 40)
        loginButton.align(.top, to: view, inset: UIScreen.isIphoneX() ? 44 : 20)
        view.addSubview(logoImageView)
        logoImageView.constrain(width: 130, height: 130)
        logoImageView.centerX(to: view)
        logoImageView.align(.top, to: view, inset: 100)
        view.addSubview(bottomLabel)
        bottomLabel.centerX(to: view)
        bottomLabel.align(.bottom, to: view, inset: 20)
        view.addSubview(registerButton)
        registerButton.align(.left, to: view, inset: 28)
        registerButton.align(.right, to: view, inset: 28)
        registerButton.constrain(height: 50)
        registerButton.pin(.top, to: bottomLabel, spacing: -20)
        registerButton.setViewRounded()
    }
}
