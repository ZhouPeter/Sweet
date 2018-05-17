//
//  ChoiceCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

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
    }
    
    func updateWith(_ viewModel: ChoiceCardViewModel) {
        titleLabel.text = viewModel.titleString
        contentLabel.text = viewModel.contentString
        leftButton.kf.setBackgroundImage(with: viewModel.imageURL[0], for: .normal)
        rightButton.kf.setBackgroundImage(with: viewModel.imageURL[1], for: .normal)
    
    }
}
