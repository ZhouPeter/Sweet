//
//  UpdateNicknameController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol UpdateProtocol {
    var saveCompletion: ((String) -> Void)? { get set }
}

class UpdateNicknameController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String) -> Void)?
    
    var nickname: String
    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.text = nickname
        textField.textColor = .black
        textField.tintColor = .black
        textField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "长度限制：1~8个字"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("保存", for: .normal)
        button.isUserInteractionEnabled = false
        button.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        return button
    }()
    
    init(nickname: String) {
        self.nickname = nickname
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpGray()
        navigationItem.title = "修改昵称"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        setupUI()
    }

    private func setupUI() {
        let topContentView = BorderContentView()
        topContentView.backgroundColor = .white
        view.addSubview(topContentView)
        topContentView.align(.left, to: view)
        topContentView.align(.right, to: view)
        topContentView.align(.top, to: view, inset: 10 + UIScreen.navBarHeight())
        topContentView.constrain(height: 56)
        topContentView.addSubview(nicknameTextField)
        nicknameTextField.fill(in: topContentView, left: 10)
        view.addSubview(infoLabel)
        infoLabel.align(.left, to: view, inset: 10)
        infoLabel.pin(.bottom, to: topContentView, spacing: 10)

    }
    
    @objc private func saveAction(_ sender: UIButton) {
        guard let text = nicknameTextField.text, text != "", text != nickname else { return }
        web.request(.update(
            updateParameters: ["nickname": text, "type": UpdateUserType.nickname.rawValue])) { [weak self] (result) in
            switch result {
            case .success:
                self?.saveCompletion?(text)
                self?.navigationController?.popViewController(animated: true)
            case .failure:
                self?.toast(message: "保存失败", duration: 2)
            }
        }
    }
    
    @objc private func textFieldEditChanged(_ textField: UITextField) {
        if let text = textField.text, text.count > 0, text != nickname {
            saveButton.setTitleColor(UIColor.black, for: .normal)
            saveButton.isUserInteractionEnabled = true
        } else {
            saveButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            saveButton.isUserInteractionEnabled = false
        }
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
