//
//  NewsCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class NewsCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    
    func updateWith(_ viewModel: NewsCardViewModel) {
        
    }
    
    typealias ViewModelType = NewsCardViewModel
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(contentLabel)
        contentLabel.align(.left, to: contentView, inset: 20)
        contentLabel.align(.right, to: contentView, inset: 20)
        contentLabel.pin(to: titleLabel, edge: .bottom, spacing: 15)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
