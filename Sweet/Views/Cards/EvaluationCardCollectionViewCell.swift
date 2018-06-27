//
//  EvaluationCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol EvaluationCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    func selectEvaluationCard(cell: EvaluationCardCollectionViewCell, cardId: String, selectedIndex: Int)
}
class EvaluationCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    typealias ViewModelType = EvaluationCardViewModel
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
        return imageView
    }()
    
    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tag = 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectAction(_:)))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var selectedButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "SelectedChoice"), for: .normal)
        button.isHidden = true
        return button
    }()
    private var selectedButtonCenterXLeftConstraint: NSLayoutConstraint?
    private var selectedButtonCenterXRightConstraint: NSLayoutConstraint?
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
        selectedButton.centerY(to: leftImageView)
        selectedButtonCenterXLeftConstraint = selectedButton.centerX(to: leftImageView)
        selectedButtonCenterXRightConstraint = selectedButton.centerX(to: rightImageView)
        selectedButtonCenterXLeftConstraint?.isActive = true
        selectedButtonCenterXRightConstraint?.isActive = false
    }
    
    func updateWith(_ viewModel: EvaluationCardViewModel) {
        cardId = viewModel.cardId
        titleLabel.text = viewModel.titleString
        contentLabel.attributedText = viewModel.contentTextAttributed
        leftImageView.kf.setImage(with: viewModel.imageURL[0].middleCutting(size: leftImageView.frame.size))
        rightImageView.kf.setImage(with: viewModel.imageURL[1].middleCutting(size: leftImageView.frame.size))
        if let selectedIndex = viewModel.selectedIndex {
            if selectedIndex == 0 {
                selectedButtonCenterXRightConstraint?.isActive = false
                selectedButtonCenterXLeftConstraint?.isActive = true
                selectedButton.isHidden = false
            } else {
                selectedButtonCenterXLeftConstraint?.isActive = false
                selectedButtonCenterXRightConstraint?.isActive = true
                selectedButton.isHidden = false
            }
        } else {
            selectedButton.isHidden = true
        }
    }
    
    func updateWith(_ selectedIndex: Int) {
        if selectedIndex == 0 {
            selectedButtonCenterXRightConstraint?.isActive = false
            selectedButtonCenterXLeftConstraint?.isActive = true
            selectedButton.isHidden = false
        } else {
            selectedButtonCenterXLeftConstraint?.isActive = false
            selectedButtonCenterXRightConstraint?.isActive = true
            selectedButton.isHidden = false
        }
    }
    @objc private func selectAction(_ tap: UITapGestureRecognizer) {
        if let delegate = delegate as? EvaluationCardCollectionViewCellDelegate {
            if let cardId = cardId {
                if selectedButton.isHidden, let tag = tap.view?.tag {
                    delegate.selectEvaluationCard(cell: self, cardId: cardId, selectedIndex: tag)
                }
            }
        }
    }
}
