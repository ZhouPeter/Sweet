//
//  UpdateSignatureController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateSignatureController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String, Int?) -> Void)?
    
    var signature: String
    private lazy var signatureTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 0)
        textView.isScrollEnabled = false
        textView.delegate = self
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "编辑个人介绍"
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "30"
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("保存", for: .normal)
        button.isEnabled = false
        button.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .disabled)
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "个人介绍"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        view.backgroundColor = UIColor.xpGray()
        setupUI()
        signatureTextView.text = signature
        placeholderLabel.isHidden = signature != ""
        if #available(iOS 11.0, *) {
            self.signatureTextView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    init(signature: String) {
        self.signature = signature
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let borderContentView = BorderContentView()
        borderContentView.backgroundColor = .white
        view.addSubview(borderContentView)
        borderContentView.align(.top, to: view, inset: UIScreen.navBarHeight() + 10)
        borderContentView.align(.left, to: view)
        borderContentView.align(.right, to: view)
        borderContentView.constrain(height: 176)
        borderContentView.addSubview(signatureTextView)
        signatureTextView.fill(in: borderContentView)
        borderContentView.addSubview(placeholderLabel)
        placeholderLabel.align(.left, to: borderContentView, inset: 8)
        placeholderLabel.align(.top, to: borderContentView, inset: 15)
        borderContentView.addSubview(countLabel)
        countLabel.align(.right, to: borderContentView, inset: 10)
        countLabel.align(.bottom, to: borderContentView, inset: 10)

    }
    
    @objc private func saveAction(_ sender: UIButton) {
        web.request(.update(updateParameters: ["signature": signatureTextView.text,
                                               "type": UpdateUserType.signature.rawValue])) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                self.signature = self.signatureTextView.text
                let remain = response["remain"] as? Int
                self.saveCompletion?(self.signature, remain)
                self.navigationController?.popViewController(animated: true)
            case let .failure(error):
                if error.code == WebErrorCode.updateLimit.rawValue {
                    self.toast(message: "修改次数已用完")
                } else {
                    self.toast(message: "修改失败")
                }
                logger.error(error)
            }
        }
    }

}

extension UpdateSignatureController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        if textView.text.count > 30 {
            let startIndex = textView.text.startIndex
            let endIndex = textView.text.index(startIndex, offsetBy: 30)
            textView.text = String(textView.text[startIndex..<endIndex])
        }
        countLabel.text = "\(30 - textView.text.count)"
        if textView.text != signature {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}
