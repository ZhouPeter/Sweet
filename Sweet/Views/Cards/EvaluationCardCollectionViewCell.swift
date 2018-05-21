//
//  EvaluationCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class EvaluationCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    typealias ViewModelType = EvaluationCardViewModel
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
        selectedButton.centerY(to: leftButton)
        selectedButtonCenterXLeftConstraint = selectedButton.centerX(to: leftButton)
        selectedButtonCenterXRightConstraint = selectedButton.centerX(to: rightButton)
        selectedButtonCenterXLeftConstraint?.isActive = true
        selectedButtonCenterXRightConstraint?.isActive = false
    }
    
    func updateWith(_ viewModel: EvaluationCardViewModel) {
        titleLabel.text = viewModel.titleString
        contentLabel.text = viewModel.contentString
        leftButton.kf.setBackgroundImage(with: viewModel.imageURL[0], for: .normal)
        rightButton.kf.setBackgroundImage(with: viewModel.imageURL[1], for: .normal)
        if viewModel.selectedIndex == 0 {
            selectedButtonCenterXLeftConstraint?.isActive = true
            selectedButtonCenterXRightConstraint?.isActive = false
            selectedButton.isHidden = false
        } else {
            selectedButtonCenterXLeftConstraint?.isActive = false
            selectedButtonCenterXRightConstraint?.isActive = true
            selectedButton.isHidden = false
        }
    }
}
