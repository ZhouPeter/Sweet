//
//  ChoiceCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ChoiceCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    
}
class ChoiceCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {

    typealias ViewModelType = ChoiceCardViewModel
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var leftMaskView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var rightMaskView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var leftPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "28%"
        return label
    }()
    
    private lazy var rightPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "28%"
        return label
    }()
    
    private lazy var leftImageViews: [UIImageView] = {
        let imageViews = [UIImageView(), UIImageView(), UIImageView()]
        return imageViews
    }()
    
    private lazy var rightImageViews: [UIImageView] = {
        let imageViews = [UIImageView(), UIImageView(), UIImageView()]
        return imageViews
    }()

    private lazy var selectedButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "SelectedChoice"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    private var selectedButtonCenterXLeftConstraint: NSLayoutConstraint?
    private var selectedButtonCenterXRightConstraint: NSLayoutConstraint?
    private var leftPercentLabelCenterXConstraint: NSLayoutConstraint?
    private var rightPercentLabelCenterXConstraint: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        customContent.addSubview(contentLabel)
        contentLabel.align(.left, to: customContent, inset: 10)
        contentLabel.pin(.bottom, to: titleLabel, spacing: 18)
        customContent.addSubview(leftButton)
        leftButton.equal(.width, to: customContent, multiplier: 0.5, offset: -0.25)
        leftButton.align(.left, to: customContent)
        leftButton.align(.bottom, to: customContent)
        leftButton.align(.top, to: customContent, inset: 140)
        customContent.addSubview(rightButton)
        rightButton.equal(.width, to: customContent, multiplier: 0.5, offset: -0.25)
        rightButton.align(.right, to: customContent)
        rightButton.align(.bottom, to: customContent)
        rightButton.align(.top, to: leftButton)
        leftButton.setViewRounded(cornerRadius: 10, corners: .bottomLeft)
        rightButton.setViewRounded(cornerRadius: 10, corners: .bottomRight)
        customContent.addSubview(selectedButton)
        selectedButton.constrain(width: 40, height: 40)
        selectedButton.align(.top, to: leftButton, inset: 120)
        selectedButtonCenterXLeftConstraint = selectedButton.centerX(to: leftButton)
        selectedButtonCenterXRightConstraint = selectedButton.centerX(to: rightButton)
        selectedButtonCenterXRightConstraint?.isActive = false
        selectedButtonCenterXLeftConstraint?.isActive = true
        
        addButtonMaskViews()
        addImageViews()
        addPercentLabels()
    }
    
    private func addButtonMaskViews() {
        leftButton.addSubview(leftMaskView)
        leftMaskView.align(.left, to: leftButton)
        leftMaskView.align(.right, to: leftButton)
        leftMaskView.align(.bottom, to: leftButton)
        leftMaskView.constrain(height: 100)
        
        rightButton.addSubview(rightMaskView)
        rightMaskView.align(.left, to: rightButton)
        rightMaskView.align(.right, to: rightButton)
        rightMaskView.align(.bottom, to: rightButton)
        rightMaskView.constrain(height: 100)
    }
    
    private func addImageViews() {
        var leftSpacing: CGFloat = ((UIScreen.mainWidth() - 20 - 1) / 2 - 60 - 42 - 10) / 2 + 30
        leftImageViews.forEach { (imageView) in
            leftMaskView.addSubview(imageView)
            imageView.constrain(width: 30, height: 30)
            imageView.centerY(to: leftMaskView)
            imageView.align(.left, to: leftMaskView, inset: leftSpacing)
            imageView.setViewRounded()
            leftSpacing -= 15
        }
        var rightSpacing: CGFloat = ((UIScreen.mainWidth() - 20 - 1) / 2 - 60 - 42 - 10) / 2 + 30
        rightImageViews.forEach { (imageView) in
            rightMaskView.addSubview(imageView)
            imageView.constrain(width: 30, height: 30)
            imageView.centerY(to: rightMaskView)
            imageView.align(.left, to: rightMaskView, inset: rightSpacing)
            imageView.setViewRounded()
            rightSpacing -= 15
        }
    }
    
    private func addPercentLabels() {
        leftMaskView.addSubview(leftPercentLabel)
        leftPercentLabel.centerY(to: leftMaskView)
        let leftPercentLabelRightConstraint = leftPercentLabel.pin(.right, to: leftImageViews[0], spacing: 10)
        leftPercentLabelRightConstraint.priority = .defaultHigh
        leftPercentLabelCenterXConstraint = leftPercentLabel.centerX(to: leftMaskView)
        leftPercentLabelCenterXConstraint?.priority = .defaultLow
        
        rightMaskView.addSubview(rightPercentLabel)
        rightPercentLabel.centerY(to: rightMaskView)
        let rightPercentLabelRightConstraint = rightPercentLabel.pin(.right, to: rightImageViews[0], spacing: 10)
        rightPercentLabelRightConstraint.priority = .defaultHigh
        rightPercentLabelCenterXConstraint = rightPercentLabel.centerX(to: rightMaskView)
        rightPercentLabelCenterXConstraint?.priority = .defaultLow
    }
    
    func updateWith(_ viewModel: ChoiceCardViewModel) {
        cardId = viewModel.cardId
        titleLabel.text = viewModel.titleString
        contentLabel.text = viewModel.contentString
        leftButton.kf.setBackgroundImage(with: viewModel.imageURL[0], for: .normal)
        rightButton.kf.setBackgroundImage(with: viewModel.imageURL[1], for: .normal)
        if let selectedIndex = viewModel.selectedIndex, let urls = viewModel.avatarURLs {
            selectedUIHidden(isHidden: false)
            if selectedIndex == 0 {
                selectedButtonCenterXLeftConstraint?.isActive = true
                selectedButtonCenterXRightConstraint?.isActive = false
                leftImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                for (offset, url) in urls.enumerated() {
                    leftImageViews[offset].isHidden = false
                    leftImageViews[offset].kf.setImage(with: url)
                }
                leftMaskView.backgroundColor = UIColor(hex: 0x9b9b9b).withAlphaComponent(0.5)
                leftPercentLabelCenterXConstraint?.priority = .defaultLow
                rightImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                rightMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                rightPercentLabelCenterXConstraint?.priority = UILayoutPriority.init(rawValue: 999)
            } else if selectedIndex == 1 {
                selectedButtonCenterXLeftConstraint?.isActive = false
                selectedButtonCenterXRightConstraint?.isActive = true
                rightImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                for (offset, url) in urls.enumerated() {
                    rightImageViews[offset].isHidden = false
                    rightImageViews[offset].kf.setImage(with: url)
                }
                rightMaskView.backgroundColor = UIColor(hex: 0x9b9b9b).withAlphaComponent(0.5)
                rightPercentLabelCenterXConstraint?.priority = .defaultLow
                leftImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                leftMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                leftPercentLabelCenterXConstraint?.priority = UILayoutPriority.init(rawValue: 999)
            }
        } else {
           selectedUIHidden(isHidden: true)
        }
    }
    
    private func selectedUIHidden(isHidden: Bool) {
        leftMaskView.isHidden = isHidden
        rightMaskView.isHidden = isHidden
        leftPercentLabel.isHidden = isHidden
        rightPercentLabel.isHidden = isHidden
        leftImageViews.forEach { (imageView) in
            imageView.isHidden = isHidden
        }
        rightImageViews.forEach { (imageView) in
            imageView.isHidden = isHidden
        }
        selectedButton.isHidden = isHidden
    }
}
