//
//  SignUpNameController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SignUpNameController: BaseViewController, SignUpNameView {
    var showSignUpAvatar: ((LoginRequestBody) -> Void)?
    
    var loginRequestBody: LoginRequestBody!
    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 30)
        textField.textColor = .black
        textField.tintColor = .black
        textField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "tips：一个真实的名字，能让你避免被朋友当做路人"
        return label
    }()
    private lazy var nextButton: ShrinkButton = {
        let button = ShrinkButton()
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "你的名字"
        navigationController?.navigationBar.barTintColor = UIColor.xpYellow()
        view.backgroundColor = UIColor.xpYellow()
        setupUI()
        nicknameTextField.becomeFirstResponder()

    }
    private func setupUI() {
        view.addSubview(nicknameTextField)
        nicknameTextField.align(.top, to: view, inset: UIScreen.navBarHeight() + 144)
        nicknameTextField.centerX(to: view)
        nicknameTextField.align(.left, to: view, inset: 50)
        nicknameTextField.align(.right, to: view, inset: 50)
        view.addSubview(tipsLabel)
        tipsLabel.centerX(to: view)
        tipsLabel.pin(to: nicknameTextField, edge: .bottom, spacing: -120)
        view.addSubview(nextButton)
        nextButton.pin(to: tipsLabel, edge: .bottom, spacing: -10)
        nextButton.align(.left, to: view, inset: 28)
        nextButton.align(.right, to: view, inset: 28)
        nextButton.constrain(height: 50)
        nextButton.setViewRounded()
    }
    
    @objc private func nextAction(_ sender: ShrinkButton) {
        if nicknameTextField.text == "" {
            toast(message: "名字不能为空", duration: 2)
            return
        }
        loginRequestBody.nickname = nicknameTextField.text
        let message = "请确认你的名字，若该名字不能被朋友认出，你被朋友选中的几率将大大降低"
        let alertController = UIAlertController(title: loginRequestBody.nickname,
                                                message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "返回修改", style: .cancel, handler: nil)
        let doneAction = UIAlertAction(title: "确认无误", style: .default) { [weak self] (_) in
            if let `self` = self, let model = self.loginRequestBody {
                self.showSignUpAvatar?(model)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        alertController.preferredAction = doneAction
        present(alertController, animated: true, completion: nil)
    }
}

extension SignUpNameController {
    @objc private func textFieldEditChanged(_ textField: UITextField) {
        if let selectedRange = textField.markedTextRange {
            let position: UITextPosition? = textField.position(from: selectedRange.start, offset: 0)
            let text = textField.text?.substringLans(kMaxLength: 16, position: position)
            if let text = text {
                logger.debug(text)
                textField.text = text
            }
        } else {
            let text = textField.text?.substringLans(kMaxLength: 16, position: nil)
            if let text = text {
                logger.debug(text)
                textField.text = text
            }
        }
    }
}
