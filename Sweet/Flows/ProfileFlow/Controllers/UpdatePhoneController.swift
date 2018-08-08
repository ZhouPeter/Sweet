//
//  UpdatePhoneController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdatePhoneController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String, Int?) -> Void)?
    
    var phone: String
    var smsCode: String = ""
    private lazy var countryNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        label.text = "+86"
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var phoneTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "输入手机号码"
        textField.keyboardType = .phonePad
        textField.textColor = .black
        textField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var smsCodeButton: UIButton = {
        let button = UIButton()
        button.setTitle("获取验证码", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(sendCode(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var smsCodeTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .phonePad
        textField.textColor = .black
        textField.placeholder = "输入验证码"
        textField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.numberOfLines = 0
        let text = "当前手机号：" + phone.phoneMiddleHidden() + "\n更换手机后，下次登录可使用新手机号登录"
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 9
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("提交", for: .normal)
        button.isUserInteractionEnabled = false
        button.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        return button
    }()

    init(phone: String) {
        self.phone = phone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "手机验证"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        view.backgroundColor = UIColor.xpGray()
        setupUI()
        phoneTextField.resignFirstResponder()
    }
    
    // swiftlint:disable function_body_length
    private func setupUI() {
        let borderTopView = BorderContentView()
        view.addSubview(borderTopView)
        borderTopView.align(.left, to: view)
        borderTopView.align(.right, to: view)
        borderTopView.align(.top, to: view, inset: UIScreen.navBarHeight() + 10)
        borderTopView.constrain(height: 56)
        borderTopView.addSubview(countryNumLabel)
        countryNumLabel.align(.left, to: borderTopView)
        countryNumLabel.centerY(to: borderTopView)
        countryNumLabel.constrain(width: 60)
        
        let leftLineView = UIView()
        leftLineView.backgroundColor = UIColor.xpSeparatorGray()
        borderTopView.addSubview(leftLineView)
        leftLineView.align(.top, to: borderTopView)
        leftLineView.align(.bottom, to: borderTopView)
        leftLineView.pin(.right, to: countryNumLabel)
        leftLineView.constrain(width: 0.5)
        
        borderTopView.addSubview(smsCodeButton)
        smsCodeButton.align(.right, to: borderTopView)
        smsCodeButton.align(.top, to: borderTopView)
        smsCodeButton.align(.bottom, to: borderTopView)
        smsCodeButton.constrain(width: 120)
        
        let rightLineView = UIView()
        rightLineView.backgroundColor = UIColor.xpSeparatorGray()
        borderTopView.addSubview(rightLineView)
        rightLineView.align(.top, to: borderTopView)
        rightLineView.align(.bottom, to: borderTopView)
        rightLineView.pin(.left, to: smsCodeButton, spacing: 1)
        rightLineView.constrain(width: 0.5)

        borderTopView.addSubview(phoneTextField)
        phoneTextField.pin(.right, to: leftLineView, spacing: 20)
        phoneTextField.pin(.left, to: rightLineView)
        phoneTextField.align(.top, to: borderTopView)
        phoneTextField.align(.bottom, to: borderTopView)
        
        let borderBottomView = BorderContentView()
        view.addSubview(borderBottomView)
        borderBottomView.align(.left, to: view)
        borderBottomView.align(.right, to: view)
        borderBottomView.pin(.bottom, to: borderTopView, spacing: 10)
        borderBottomView.constrain(height: 56)
        borderBottomView.addSubview(smsCodeTextField)
        smsCodeTextField.fill(in: borderBottomView, left: 15)
        view.addSubview(messageLabel)
        messageLabel.align(.left, to: view, inset: 15)
        messageLabel.pin(.bottom, to: borderBottomView, spacing: 15)
    }
    
    @objc private func saveAction(_ sender: UIButton) {
        guard let phone = phoneTextField.text, phone.checkPhone(), let smsCode = smsCodeTextField.text  else { return }
        web.request(.phoneChange(phone: phone, code: smsCode)) { [weak self] (result) in
            switch result {
            case let .success(response):
                let remain = response["remain"] as? Int
                self?.saveCompletion?(phone, remain)
                self?.navigationController?.popViewController(animated: true)
            case let .failure(error):
                if error.code == WebErrorCode.updateLimit.rawValue {
                    self?.toast(message: "修改次数已用完")
                } else {
                    self?.toast(message: "修改失败")
                }
                logger.error(error)
            }
        }
    }
    
    @objc private func sendCode(_ sender: UIButton) {
        if let phone = phoneTextField.text, phone.checkPhone() {
            sender.isEnabled = false
            web.request(.sendCode(phone: phone, type: .changeNumber)) { [weak self] (result) in
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
                    self?.toast(message: "发送失败")
                    sender.isEnabled = true
                    logger.error(error)
                }
            }
        } else {
            self.toast(message: "你的手机号码不正确")
        }
    }
    @objc private func textFieldEditChanged(_ textField: UITextField) {
        if textField == smsCodeTextField {
            if let text = textField.text, text.count > 0 {
                saveButton.setTitleColor(.black, for: .normal)
                saveButton.isUserInteractionEnabled = true
            } else {
                saveButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
                saveButton.isUserInteractionEnabled = false
            }
        } else if textField == phoneTextField {
            if let text = textField.text, text.count > 11 {
                textField.text = String(text[text.startIndex..<text.index(text.startIndex, offsetBy: 11)])
            }
        }
    }
}
