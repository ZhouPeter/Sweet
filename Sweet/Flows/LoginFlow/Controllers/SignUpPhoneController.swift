//
//  SignUpPhoneController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Contacts
import SwiftyUserDefaults
let loginedKey = DefaultsKey<Bool>("logined") // 定义了你的key

class SignUpPhoneController: BaseViewController, SignUpPhoneView {
    var onFinish: ((Bool) -> Void)?
    var showSetting: (() -> Void)?
    var loginRequestBody: LoginRequestBody!
    override var prefersStatusBarHidden: Bool {
        return false
    }
    private var storage: Storage?
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
        button.setTitleColor(.gray, for: .disabled)
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
        button.backgroundColor = UIColor.xpNavBlue()
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
    
    private let isLogin: Bool
    
    init(isLogin: Bool) {
        self.isLogin = isLogin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpYellow()
        navigationItem.title = "手机验证"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.xpYellow()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressView(_:)))
        view.addGestureRecognizer(tap)
        setupUI()
    }
    
    @objc private func didPressView(_ tap: UITapGestureRecognizer) {
        view.endEditing(true)
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
        phoneTextField.pin(.right, to: codeLabel)
        phoneTextField.pin(.left, to: smsCodeButton)
        phoneTextField.constrain(height: 40)
        phoneTextField.centerY(to: codeLabel)
        
        view.addSubview(topLineView)
        topLineView.align(.left, to: view, inset: 16)
        topLineView.align(.right, to: view, inset: 16)
        topLineView.pin(.bottom, to: codeLabel, spacing: 14)
        topLineView.constrain(height: UIScreen.onePixel())
        
        view.addSubview(smsCodeTextField)
        smsCodeTextField.centerX(to: view)
        smsCodeTextField.pin(.bottom, to: topLineView, spacing: 10)
        smsCodeTextField.constrain(width: 240, height: 50)
        
        view.addSubview(bottomLineView)
        bottomLineView.align(.left, to: view, inset: 16)
        bottomLineView.align(.right, to: view, inset: 16)
        bottomLineView.pin(.bottom, to: smsCodeTextField, spacing: 5)
        bottomLineView.constrain(height: UIScreen.onePixel())
        
        view.addSubview(enterButton)
        enterButton.constrain(height: 50)
        enterButton.align(.left, to: view, inset: 28)
        enterButton.align(.right, to: view, inset: 28)
        enterButton.pin(.bottom, to: smsCodeTextField, spacing: 120)
        enterButton.setViewRounded()
    }
    
    @objc private func sendCode(_ sender: UIButton) {
        if let phone = loginRequestBody.phone, phone.checkPhone() {
            sender.isEnabled = false
            web.request(.sendCode(phone: phone, type: isLogin ? .login : .register)) { [weak self] (result) in
                switch result {
                case .success:
                    self?.toast(message: "发送成功")
                    TimerHelper.countDown(time: 60, countDownBlock: { (timeout) in
                        sender.setTitle("剩余\(timeout)秒", for: .normal)
                    }, endBlock: {
                        sender.setTitle("获取验证码", for: .normal)
                        sender.isEnabled = true
                    })
                case let .failure(error):
                    if error.code == WebErrorCode.userIsNil.rawValue {
                        self?.toast(message: "手机号未注册")
                    } else {
                        self?.toast(message: "发送失败")
                    }
                    sender.isEnabled = true
                    logger.error(error)
                }
            }
        } else {
            self.toast(message: "你的手机号码不正确")
        }
    }
    
    @objc private func enteringAction(_ sender: UIButton) {
        if let text = phoneTextField.text, !text.checkPhone() {
            self.toast(message: "你的手机号码不正确")
            return
        }
        web.request(
            .login(body: loginRequestBody),
            responseType: Response<LoginResponse>.self,
            completion: { result in
                switch result {
                case let .failure(error):
                    if error.code == WebErrorCode.verification.rawValue {
                        self.toast(message: "手机号或验证码输入错误")
                    }
                    logger.error(error)
                case let.success(response):
                    logger.debug(response)
                    web.tokenSource.token = response.token
                    Defaults[.token] =  response.token
                    Defaults[.userID] = "\(response.user.userId)"
                    self.storage = Storage(userID: response.user.userId)
                    self.storage?.write({ (realm) in
                        let user = UserData()
                        user.userID = Int64(response.user.userId)
                        user.university = response.user.universityName
                        user.college = response.user.collegeName
                        user.avatarURLString = response.user.avatar
                        user.phone = response.user.phone
                        user.nickname = response.user.nickname
                        realm.add(user, update: true)
                    }, callback: { (_) in
                        if !response.register && self.loginRequestBody.register {
                            self.toast(
                                message: "你的账号已存在，正在自动登录",
                                duration: 3,
                                completion: {
                                    self.successLogin(loginResponse: response)
                            })
                        } else {
                            self.successLogin(loginResponse: response)
                        }
                    })
                    if let setting = response.setting {
                        self.storage?.write({ (realm) in
                            realm.create(SettingData.self, value: SettingData.data(with: setting), update: true)
                        })
                    }
                    
                }
        })
    }
    
    private func successLogin(loginResponse: LoginResponse) {
        let logined = Defaults[loginedKey]
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
        Defaults[loginedKey] = true
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
