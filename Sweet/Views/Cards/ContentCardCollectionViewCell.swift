//
//  NewsCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ContentCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    
    typealias ViewModelType = ContentCardViewModel
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private var contentImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        customContent.addSubview(contentLabel)
        contentLabel.align(.left, to: customContent, inset: 10)
        contentLabel.align(.right, to: customContent, inset: 10)
        contentLabel.pin(.bottom, to: titleLabel, spacing: 15)
        customContent.addSubview(contentImageView)
        contentImageView.align(.left, to: customContent)
        contentImageView.align(.right, to: customContent)
        contentImageView.align(.bottom, to: customContent)
        contentImageView.pin(.bottom, to: contentLabel, spacing: 5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(_ viewModel: ContentCardViewModel) {
        contentLabel.text = viewModel.contentString
        contentImageView.kf.setImage(with: viewModel.imageURL)
        contentImageView.setViewRounded(cornerRadius: 10, corners: [.bottomLeft, .bottomRight])
    }
}
