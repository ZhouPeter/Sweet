//
//  FeedbackController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol FeedbackView: BaseView {}

class SubmitTypeView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Selected")
        imageView.isHidden = true
        return imageView
    }()
    
    init(title: String, isSelected: Bool = false) {
        super.init(frame: .zero)
        setupUI()
        titleLabel.text = title
        selectedImageView.isHidden = !isSelected
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(titleLabel)
        titleLabel.centerY(to: self)
        titleLabel.align(.left, inset: 10)
        addSubview(selectedImageView)
        selectedImageView.constrain(width: 16, height: 16)
        selectedImageView.centerY(to: self)
        selectedImageView.align(.right, inset: 10)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class FeedbackController: BaseViewController, FeedbackView {
    private lazy var submitTypeSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "提交类型"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black.withAlphaComponent(0.3)
        label.textAlignment = .left
    
        return label
    }()
    private lazy var contentSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "说明内容"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black.withAlphaComponent(0.3)
        label.textAlignment = .left
      
        return label
    }()
    
    private lazy var feedbackView: SubmitTypeView = {
        let view = SubmitTypeView(title: "意见反馈", isSelected: true)
        view.tag = 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressTypeView(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var appealView: SubmitTypeView = {
        let view = SubmitTypeView(title: "封禁申诉")
        view.tag = 2
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressTypeView(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.delegate = self
        return textView
    }()
    
    private lazy var remainNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black.withAlphaComponent(0.35)
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "100"
        label.textAlignment = .right
        return label
    }()
    
    private lazy var firstLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.xpSeparatorGray()
        return view
    }()
    
    private lazy var sencondLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.xpSeparatorGray()
        return view
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("提交反馈", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(hex: 0x9B9B9B).withAlphaComponent(0.35)
        button.isEnabled = false
        button.addTarget(self, action: #selector(submitAction(_:)), for: .touchUpInside)
        return button
    }()
    private var feedbackType: Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "意见反馈"
        view.backgroundColor = UIColor.xpGray()
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressView(_:)))
        view.addGestureRecognizer(tap)
        setupTextView()
    }
    
    @objc private func submitAction(_ sender: UIButton) {
        web.request(.feedback(comment: textView.text, type: feedbackType)) { (result) in
            switch result {
            case .success:
                self.toast(message: "提交成功", completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            case .failure:
                self.toast(message: "提交失败")
            }
        }
    }
    
    @objc private func didPressTypeView(_ tap: UITapGestureRecognizer) {
        if let view = tap.view {
            if view.tag == 1 {
                feedbackView.selectedImageView.isHidden = false
                appealView.selectedImageView.isHidden = true
                feedbackType = 1
            } else if view.tag == 2 {
                feedbackView.selectedImageView.isHidden = true
                appealView.selectedImageView.isHidden = false
                feedbackType = 2
            }
        }
    }
    
    @objc private func didPressView(_ tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // swiftlint:disable function_body_length
    private func setupUI() {
        view.addSubview(submitTypeSectionLabel)
        submitTypeSectionLabel.align(.top, inset: UIScreen.navBarHeight())
        submitTypeSectionLabel.align(.left, inset: 10)
        submitTypeSectionLabel.align(.right)
        submitTypeSectionLabel.constrain(height: 25)
        view.addSubview(feedbackView)
        feedbackView.align(.left)
        feedbackView.align(.right)
        feedbackView.pin(.bottom, to: submitTypeSectionLabel)
        feedbackView.constrain(height: 45)
        view.addSubview(firstLineView)
        firstLineView.align(.left)
        firstLineView.align(.right)
        firstLineView.pin(.bottom, to: feedbackView)
        firstLineView.constrain(height: 0.5)
        view.addSubview(appealView)
        appealView.align(.left)
        appealView.align(.right)
        appealView.pin(.bottom, to: firstLineView)
        appealView.constrain(height: 45)
        view.addSubview(sencondLineView)
        sencondLineView.align(.left)
        sencondLineView.align(.right)
        sencondLineView.pin(.bottom, to: appealView)
        sencondLineView.constrain(height: 0.5)
        view.addSubview(contentSectionLabel)
        contentSectionLabel.align(.left, inset: 10)
        contentSectionLabel.align(.right)
        contentSectionLabel.pin(.bottom, to: sencondLineView)
        contentSectionLabel.constrain(height: 25)
        view.addSubview(textView)
        textView.align(.left)
        textView.align(.right)
        textView.pin(.bottom, to: contentSectionLabel)
        textView.constrain(height: 200)
        view.addSubview(remainNumberLabel)
        remainNumberLabel.align(.right, inset: 10)
        remainNumberLabel.align(.top, to: textView, inset: 170)
        view.addSubview(submitButton)
        submitButton.align(.left)
        submitButton.align(.right)
        submitButton.constrain(height: 50)
        submitButton.align(.bottom, inset: UIScreen.safeBottomMargin())
    }
    
    private func setupTextView() {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "请输入反馈的具体内容"
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = UIColor.black.withAlphaComponent(0.35)
        placeholderLabel.font = UIFont.systemFont(ofSize: 18)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        textView.setValue(placeholderLabel, forKey: "_placeholderLabel")
    }
}

extension FeedbackController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let maxLength = 100
        if textView.text.count > maxLength {
            let startIndex = textView.text.startIndex
            let endIndex = textView.text.index(startIndex, offsetBy: maxLength)
            textView.text = String(textView.text[startIndex..<endIndex])
        }
        remainNumberLabel.text = "\(maxLength - textView.text.count)"
        if textView.text.count > 0 {
            submitButton.backgroundColor = UIColor.xpBlue()
            submitButton.isEnabled = true
        } else {
            submitButton.backgroundColor = UIColor(hex: 0x9B9B9B).withAlphaComponent(0.35)
            submitButton.isEnabled = false
        }
    }
}
