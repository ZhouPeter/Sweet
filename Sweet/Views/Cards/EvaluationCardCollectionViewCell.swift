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
        customContent.addSubview(leftButton)
        leftButton.equal(.width, to: customContent, multiplier: 0.5, offset: -6.5)
        leftButton.align(.left, to: customContent, inset: 5)
        leftButton.align(.bottom, to: customContent, inset: 5)
        leftButton.align(.top, to: customContent, inset: 140)
        customContent.addSubview(rightButton)
        rightButton.equal(.width, to: customContent, multiplier: 0.5, offset: -6.5)
        rightButton.align(.right, to: customContent, inset: 5)
        rightButton.align(.bottom, to: customContent, inset: 5)
        rightButton.align(.top, to: leftButton)
        
        leftButton.setViewRounded(cornerRadius: 5, corners: .allCorners)
        rightButton.setViewRounded(cornerRadius: 5, corners: .allCorners)
        
        customContent.addSubview(selectedButton)
        selectedButton.constrain(width: 40, height: 40)
        selectedButton.centerY(to: leftButton)
        selectedButtonCenterXLeftConstraint = selectedButton.centerX(to: leftButton)
        selectedButtonCenterXRightConstraint = selectedButton.centerX(to: rightButton)
        selectedButtonCenterXLeftConstraint?.isActive = true
        selectedButtonCenterXRightConstraint?.isActive = false
    }
    
    func updateWith(_ viewModel: EvaluationCardViewModel) {
        cardId = viewModel.cardId
        titleLabel.text = viewModel.titleString
        contentLabel.text = viewModel.contentString
//        leftButton.kf.setImage(with: viewModel.imageURL[0].middleCutting(size: leftButton.frame.size), for: .normal)
//        rightButton.kf.setImage(with: viewModel.imageURL[1].middleCutting(size: leftButton.frame.size), for: .normal)
        leftButton.kf.setBackgroundImage(with: viewModel.imageURL[0].middleCutting(size: leftButton.frame.size), for: .normal)
        rightButton.kf.setBackgroundImage(with: viewModel.imageURL[1].middleCutting(size: leftButton.frame.size), for: .normal)
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
    @objc private func selectAction(sender: UIButton) {
        if let delegate = delegate as? EvaluationCardCollectionViewCellDelegate {
            if let cardId = cardId {
                if selectedButton.isHidden {
                    delegate.selectEvaluationCard(cell: self, cardId: cardId, selectedIndex: sender.tag)
                }
            }
        }
    }
}
