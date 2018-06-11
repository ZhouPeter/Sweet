//
//  ChoiceCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ChoiceCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    func selectChoiceCard(cardId: String, selectedIndex: Int)

}
class ChoiceCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {

    typealias ViewModelType = ChoiceCardViewModel
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.imageView?.contentMode = .scaleAspectFill
        button.tag = 0
        button.addTarget(self, action: #selector(selectAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.imageView?.contentMode = .scaleAspectFill
        button.tag = 1
        button.addTarget(self, action: #selector(selectAction(sender:)), for: .touchUpInside)
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
        label.shadowColor = UIColor.black.withAlphaComponent(0.5)
        label.shadowOffset = CGSize(width: 0, height: 2)
        return label
    }()
    
    private lazy var rightPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.shadowColor = UIColor.black.withAlphaComponent(0.5)
        label.shadowOffset = CGSize(width: 0, height: 2)
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
    private var leftImageContraints: [NSLayoutConstraint] =  [NSLayoutConstraint]()
    private var rightImageContraints: [NSLayoutConstraint] =  [NSLayoutConstraint]()
    private var leftMaskViewHeightConstraint: NSLayoutConstraint?
    private var rightMaskViewHeightConstraint: NSLayoutConstraint?
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
        contentLabel.align(.right, to: customContent, inset: 10)
        contentLabel.pin(.bottom, to: titleLabel, spacing: 18)
        customContent.addSubview(leftButton)
        leftButton.equal(.width, to: customContent, multiplier: 0.5)
        leftButton.align(.left, to: customContent)
        leftButton.align(.bottom, to: customContent)
        leftButton.align(.top, to: customContent, inset: 140)
        customContent.addSubview(rightButton)
        rightButton.equal(.width, to: customContent, multiplier: 0.5)
        rightButton.align(.right, to: customContent)
        rightButton.align(.bottom, to: customContent)
        rightButton.align(.top, to: leftButton)
        leftButton.setViewRounded(cornerRadius: 10, corners: .bottomLeft)
        rightButton.setViewRounded(cornerRadius: 10, corners: .bottomRight)
        customContent.addSubview(selectedButton)
        selectedButton.constrain(width: 40, height: 40)
        let offset = leftButton.bounds.height / 4
        selectedButton.centerY(to: leftButton, offset: -offset)
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
        leftMaskViewHeightConstraint = leftMaskView.constrain(height: 0)
        
        rightButton.addSubview(rightMaskView)
        rightMaskView.align(.left, to: rightButton)
        rightMaskView.align(.right, to: rightButton)
        rightMaskView.align(.bottom, to: rightButton)
        rightMaskViewHeightConstraint =  rightMaskView.constrain(height: 0)
    }
    
    private func addImageViews() {
        var leftCenterXSpacing: CGFloat = 50
        leftImageViews.forEach { (imageView) in
            leftMaskView.addSubview(imageView)
            imageView.constrain(width: 40, height: 40)
            imageView.centerY(to: leftMaskView)
            let contraint = imageView.centerX(to: leftMaskView, offset: -leftCenterXSpacing)
            leftImageContraints.append(contraint!)
            imageView.setViewRounded()
            leftCenterXSpacing -= 50
        }
        var rightCenterXSpacing: CGFloat = 50
        rightImageViews.forEach { (imageView) in
            rightMaskView.addSubview(imageView)
            imageView.constrain(width: 40, height: 40)
            imageView.centerY(to: rightMaskView)
            let contraint = imageView.centerX(to: rightMaskView, offset: -rightCenterXSpacing)
            rightImageContraints.append(contraint!)
            imageView.setViewRounded()
            rightCenterXSpacing -= 50
        }
    }
    
    private func addPercentLabels() {
        leftMaskView.addSubview(leftPercentLabel)
        leftPercentLabel.centerX(to: leftMaskView)
        leftPercentLabel.pin(.top, to: leftMaskView)
        
        rightMaskView.addSubview(rightPercentLabel)
        rightPercentLabel.centerX(to: rightMaskView)
        rightPercentLabel.pin(.top, to: rightMaskView)
    }
    
    // swiftlint:disable function_body_length
    func updateWith(_ viewModel: ChoiceCardViewModel) {
        cardId = viewModel.cardId
        titleLabel.text = viewModel.titleString
        contentLabel.text = viewModel.contentString
        leftButton.kf.setImage(with: viewModel.imageURL[0], for: .normal)
        rightButton.kf.setImage(with: viewModel.imageURL[1], for: .normal)
        if let selectedIndex = viewModel.selectedIndex,
           let urls = viewModel.avatarURLs,
           let percent = viewModel.percent {
            selectedUIHidden(isHidden: false)
            let sumButtonWidth: CGFloat = CGFloat(urls.count * 40 + (urls.count - 1) * 10)
            if selectedIndex == 0 {
                selectedButtonCenterXRightConstraint?.isActive = false
                selectedButtonCenterXLeftConstraint?.isActive = true
                leftImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                for (offset, url) in urls.enumerated() {
                    leftImageViews[offset].isHidden = false
                    leftImageViews[offset].kf.setImage(with: url)
                    let offsetCenterX: CGFloat = 40.0 / 2 + CGFloat(offset) * 50  - sumButtonWidth / 2
                    leftImageContraints[offset].constant = offsetCenterX
                }
                leftMaskView.backgroundColor = UIColor(hex: 0x9b9b9b).withAlphaComponent(0.5)
                rightImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                rightMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                leftPercentLabel.text = String(format: "%.0f%@", percent, "%")
                rightPercentLabel.text = String(format: "%.0f%@", 100 - percent, "%")
                let sumHeight = leftButton.bounds.height / 2 - 50
                leftMaskViewHeightConstraint?.constant = 50 + sumHeight * CGFloat(percent) / 100
                rightMaskViewHeightConstraint?.constant = 50 + sumHeight * (1 - CGFloat(percent) / 100)

            } else if selectedIndex == 1 {
                selectedButtonCenterXLeftConstraint?.isActive = false
                selectedButtonCenterXRightConstraint?.isActive = true
                rightImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                for (offset, url) in urls.enumerated() {
                    rightImageViews[offset].isHidden = false
                    rightImageViews[offset].kf.setImage(with: url)
                    let offsetCenterX: CGFloat = 40.0 / 2 + CGFloat(offset) * 50  - sumButtonWidth / 2
                    rightImageContraints[offset].constant = offsetCenterX
                }
                rightMaskView.backgroundColor = UIColor(hex: 0x9b9b9b).withAlphaComponent(0.5)
                leftImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                leftMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                rightPercentLabel.text = String(format: "%.0f%@", percent, "%")
                leftPercentLabel.text = String(format: "%.0f%@", 100 - percent, "%")
                let sumHeight = leftButton.bounds.height / 2 - 50
                rightMaskViewHeightConstraint?.constant = 50 + sumHeight * CGFloat(percent) / 100
                leftMaskViewHeightConstraint?.constant = 50 + sumHeight * (1 - CGFloat(percent) / 100)
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
    
    @objc private func selectAction(sender: UIButton) {
        if let delegate  = delegate as? ChoiceCardCollectionViewCellDelegate {
            if let cardId = cardId, selectedButton.isHidden {
                delegate.selectChoiceCard(cardId: cardId, selectedIndex: sender.tag)
            }
        }
    }
}
