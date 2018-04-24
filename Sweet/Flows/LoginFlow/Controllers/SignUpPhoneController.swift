//
//  SignUpPhoneController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Contacts
let loginedKey = "loginedKey"
class SignUpPhoneController: BaseViewController, SignUpPhoneView {
    var onFinish: ((Bool) -> Void)?
    
    var showSetting: (() -> Void)?
    
    var loginRequestBody: LoginRequestBody!
    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "+86 |"
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var phoneTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .phonePad
        textField.placeholder = "输入手机号码"
        textField.font = UIFont.boldSystemFont(ofSize: 17)
        textField.textColor = .black
        textField.setValue(UIColor.black.withAlphaComponent(0.5), forKeyPath: "_placeholderLabel.textColor")
        textField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var smsCodeButton: UIButton = {
        let button = UIButton()
        button.setTitle("获取验证码", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(sendCode(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var smsCodeTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .phonePad
        textField.placeholder = "输入验证码"
        textField.font = UIFont.boldSystemFont(ofSize: 17)
        textField.textColor = .black
        textField.setValue(UIColor.black.withAlphaComponent(0.5), forKeyPath: "_placeholderLabel.textColor")
        textField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var enterButton: ShrinkButton = {
        let button = ShrinkButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("进入", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = .black
        button.alpha = 0.5
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(enteringAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var topLineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.xpSeparatorGray()
        return line
    }()
    
    private lazy var bottomLineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.xpSeparatorGray()
        return line
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpYellow()
        navigationItem.title = "手机验证"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.xpYellow()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(codeLabel)
        codeLabel.align(.left, to: view, inset: 16)
        codeLabel.align(.top, to: view, inset: UIScreen.navBarHeight() + 100)
        codeLabel.constrain(width: 60, height: 22)
        
        view.addSubview(smsCodeButton)
        smsCodeButton.align(.right, to: view, inset: 16)
        smsCodeButton.constrain(width: 100, height: 40)
        smsCodeButton.centerY(to: codeLabel)
        
        view.addSubview(phoneTextField)
        phoneTextField.pin(to: codeLabel, edge: .right)
        phoneTextField.pin(to: smsCodeButton, edge: .left)
        phoneTextField.size(.height, to: codeLabel)
        phoneTextField.centerY(to: codeLabel)
        
        view.addSubview(topLineView)
        topLineView.align(.left, to: view, inset: 16)
        topLineView.align(.right, to: view, inset: 16)
        topLineView.pin(to: codeLabel, edge: .bottom, spacing: -14)
        topLineView.constrain(height: 0.5)
        
        view.addSubview(smsCodeTextField)
        smsCodeTextField.centerX(to: view)
        smsCodeTextField.pin(to: codeLabel, edge: .bottom, spacing: -48)
        smsCodeButton.constrain(height: 40)
        
        view.addSubview(bottomLineView)
        bottomLineView.align(.left, to: view, inset: 16)
        bottomLineView.align(.right, to: view, inset: 16)
        bottomLineView.pin(to: smsCodeTextField, edge: .bottom, spacing: -14)
        bottomLineView.constrain(height: 0.5)
        
        view.addSubview(enterButton)
        enterButton.constrain(height: 50)
        enterButton.align(.left, to: view, inset: 28)
        enterButton.align(.right, to: view, inset: 28)
        enterButton.pin(to: smsCodeTextField, edge: .bottom, spacing: -120)
        enterButton.setViewRounded()
    }
    
    @objc private func sendCode(_ sender: UIButton) {
        
    }
    
    @objc private func enteringAction(_ sender: UIButton) {
        if let text = phoneTextField.text, !text.checkPhone() {
            self.toast(message: "你的手机号码不正确", duration: 1)
            return
        }
        web.request(
            .login(body: loginRequestBody),
            responseType: Response<LoginResponse>.self,
            completion: { result in
                switch result {
                case let .failure(error):
                    logger.error(error)
                case let.success(response):
                    logger.debug(response)
                    if response.code == 0 {
                        web.tokenSource.token = response.data.token
                    }
                    if !response.data.register && self.loginRequestBody.register {
                        self.toast(
                            message: "你的账号已存在，正在自动登录",
                            duration: 3,
                            completion: {
                                self.successLogin(loginResponse: response.data)
                        })
                    } else {
                        self.successLogin(loginResponse: response.data)
                    }
                }
        })
    }
    private func successLogin(loginResponse: LoginResponse) {
        let def = UserDefaults.standard
        let logined = def.bool(forKey: loginedKey)
        if !logined {
            onFinish?(true)
        } else {
            if loginResponse.contactsUpload {
                onFinish?(false)
            } else {
                onFinish?(true)
            }
        }
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status ==  .authorized {
            let contacts = Contacts.getContacts()
            web.request(.uploadContacts(contacts: contacts)) { (result) in
                switch result {
                case .success:
                    logger.debug("登录上传通讯录成功")
                case let .failure(error):
                    logger.error(error)
                }
                
            }
        }
        
    }
    
    @objc private func textFieldEditChanged(_ textField: UITextField) {
        if textField == smsCodeTextField {
            loginRequestBody.smsCode = textField.text
            if let text = textField.text, text.count > 0 {
                enterButton.alpha = 1
                enterButton.isUserInteractionEnabled = true
            } else {
                enterButton.alpha = 0.5
                enterButton.isUserInteractionEnabled = false
            }
        } else if textField == phoneTextField {
            if let text = textField.text, text.count > 11 {
                textField.text = String(text[text.startIndex..<text.index(text.startIndex, offsetBy: 11)])
            }
            loginRequestBody.phone = textField.text
        }
    }

}
