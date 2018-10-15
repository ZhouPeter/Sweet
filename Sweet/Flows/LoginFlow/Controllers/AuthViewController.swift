//
//  MainViewController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SafariServices
class AuthViewController: BaseViewController, AuthView {
    var showSignUp: ((LoginRequestBody) -> Void)?
    var showLogin: ((LoginRequestBody) -> Void)?
    var loginRequestBody = LoginRequestBody()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(UIColor.xpTextGray(), for: .normal)
        button.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)
        return button
    } ()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        setNoteLabelAttributedString(label: label)
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showUserWebView(_:)))
        label.addGestureRecognizer(tap)
        return label
    } ()

    private lazy var registerButton: ShrinkButton = {
        let button = ShrinkButton()
        button.setTitle("注册", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.xpNavBlue()
        button.addTarget(self, action: #selector(registerAction(_:)), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
    } ()
    
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
        let url = URL(string: "https://mx.miaobo.me/privacy.html")!
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
//        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        let imageView = UIImageView(image: UIScreen.isNotched() ? #imageLiteral(resourceName: "LoginCoverX") : #imageLiteral(resourceName: "LoginCover"))
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        imageView.fill(in: view)
        view.addSubview(bottomLabel)
        bottomLabel.align(.bottom, to: view, inset: 20)
        bottomLabel.centerX(to: view)
        
        view.addSubview(registerButton)
        view.addSubview(loginButton)
        registerButton.align(.bottom, to: view, inset: 100)
        registerButton.align(.left, to: view, inset: 28)
        registerButton.align(.right, to: view, inset: 28)
        registerButton.constrain(height: 50)
        loginButton.equal(.size, to: registerButton)
        loginButton.centerX(to: view)
        loginButton.pin(.bottom, to: registerButton)
    }
}
