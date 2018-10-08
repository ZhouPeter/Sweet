//
//  ChoiceCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SDWebImage

protocol ChoiceCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    func selectChoiceCard(cardId: String, selectedIndex: Int)
    func showProfile(buddyID: UInt64, setTop: SetTop?)
}

extension ChoiceCardCollectionViewCellDelegate {
    func showProfile(buddyID: UInt64, setTop: SetTop?) {}
}

class ChoiceCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {

    typealias ViewModelType = ChoiceCardViewModel
    private var viewModel: ViewModelType?
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tag = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectAction(_:)))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        imageView.layer.borderColor = UIColor(hex: 0xf2f2f2).cgColor
        imageView.layer.borderWidth = 0.5
        return imageView
    }()
    
    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tag = 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectAction(_:)))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        imageView.layer.borderColor = UIColor(hex: 0xf2f2f2).cgColor
        imageView.layer.borderWidth = 0.5
        return imageView
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
        customContent.addSubview(leftImageView)
        leftImageView.equal(.width, to: customContent, multiplier: 0.5, offset: -6.5)
        leftImageView.align(.left, to: customContent, inset: 5)
        leftImageView.align(.bottom, to: customContent, inset: 5)
        leftImageView.align(.top, to: customContent, inset: 140)
        customContent.addSubview(rightImageView)
        rightImageView.equal(.width, to: customContent, multiplier: 0.5, offset: -6.5)
        rightImageView.align(.right, to: customContent, inset: 5)
        rightImageView.align(.bottom, to: customContent, inset: 5)
        rightImageView.align(.top, to: leftImageView)
        leftImageView.setViewRounded(cornerRadius: 5, corners: .allCorners)
        rightImageView.setViewRounded(cornerRadius: 5, corners: .allCorners)
        customContent.addSubview(selectedButton)
        selectedButton.constrain(width: 40, height: 40)
        let offset = leftImageView.bounds.height / 4
        selectedButton.centerY(to: leftImageView, offset: -offset)
        selectedButtonCenterXLeftConstraint = selectedButton.centerX(to: leftImageView)
        selectedButtonCenterXRightConstraint = selectedButton.centerX(to: rightImageView)
        selectedButtonCenterXRightConstraint?.isActive = false
        selectedButtonCenterXLeftConstraint?.isActive = true
        
        addButtonMaskViews()
        addImageViews()
        addPercentLabels()
    }
    
    private func addButtonMaskViews() {
        leftImageView.addSubview(leftMaskView)
        leftMaskView.align(.left, to: leftImageView)
        leftMaskView.align(.right, to: leftImageView)
        leftMaskView.align(.bottom, to: leftImageView)
        leftMaskViewHeightConstraint = leftMaskView.constrain(height: 0)
        
        rightImageView.addSubview(rightMaskView)
        rightMaskView.align(.left, to: rightImageView)
        rightMaskView.align(.right, to: rightImageView)
        rightMaskView.align(.bottom, to: rightImageView)
        rightMaskViewHeightConstraint =  rightMaskView.constrain(height: 0)
    }
    
    private func addImageViews() {
        var leftCenterXSpacing: CGFloat = 50
        var leftIndex = 0
        leftImageViews.forEach { (imageView) in
            imageView.tag = leftIndex
            leftIndex += 1
            let tap = UITapGestureRecognizer(target: self, action: #selector(didPressAvatar(_:)))
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
            imageView.addGestureRecognizer(tap)
            leftMaskView.addSubview(imageView)
            imageView.constrain(width: 40, height: 40)
            imageView.centerY(to: leftMaskView)
            let contraint = imageView.centerX(to: leftMaskView, offset: -leftCenterXSpacing)
            leftImageContraints.append(contraint!)
            imageView.setViewRounded()
            leftCenterXSpacing -= 50
        }
        var rightCenterXSpacing: CGFloat = 50
        var rightIndex = 0
        rightImageViews.forEach { (imageView) in
            imageView.tag = rightIndex
            rightIndex += 1
            let tap = UITapGestureRecognizer(target: self, action: #selector(didPressAvatar(_:)))
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
            imageView.addGestureRecognizer(tap)
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
        self.viewModel = viewModel
        titleLabel.text = viewModel.titleString
        contentLabel.attributedText = viewModel.contentTextAttributed
        leftImageView.sd_setImage(with: viewModel.imageURL[0].imageView2(size: leftImageView.bounds.size))
        rightImageView.sd_setImage(with: viewModel.imageURL[1].imageView2(size: leftImageView.bounds.size))
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
                    leftImageViews[offset].sd_setImage(with: url.imageView2(size: leftImageView.bounds.size))
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
                let sumHeight = leftImageView.bounds.height / 2 - 50
                leftMaskViewHeightConstraint?.constant = 50 + sumHeight * CGFloat(percent) / 100
                rightMaskViewHeightConstraint?.constant = 50 + sumHeight * (1 - CGFloat(percent) / 100)

            } else if selectedIndex == 1 {
                selectedButtonCenterXLeftConstraint?.isActive = false
                selectedButtonCenterXRightConstraint?.isActive = true
                rightImageViews.forEach { (imageView) in
                    imageView.isHidden = true
                }
                for (offset, url) in urls.prefix(3).enumerated() {
                    rightImageViews[offset].isHidden = false
                    rightImageViews[offset].sd_setImage(with: url.imageView2(size: rightImageView.bounds.size))
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
                let sumHeight = leftImageView.bounds.height / 2 - 50
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
    
    @objc private func selectAction(_ tap: UITapGestureRecognizer) {
        if let delegate  = delegate as? ChoiceCardCollectionViewCellDelegate {
            if let cardId = cardId, selectedButton.isHidden, let tag = tap.view?.tag {
                delegate.selectChoiceCard(cardId: cardId, selectedIndex: tag)
            }
        }
    }
    
    @objc private func didPressAvatar(_ tap: UITapGestureRecognizer) {
        if let delegate  = delegate as? ChoiceCardCollectionViewCellDelegate, let view = tap.view {
            delegate.showProfile(buddyID: viewModel!.userIDs![view.tag],
                                 setTop: SetTop(contentId: nil, preferenceId: viewModel?.preferenceId))
        }
    }
}
