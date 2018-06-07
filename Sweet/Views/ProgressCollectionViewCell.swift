//
//  ProgressCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ProgressCollectionViewCell: UICollectionViewCell {
    private lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private var progressViewRightConstraint: NSLayoutConstraint!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        contentView.addSubview(progressView)
        progressView.align(.left, to: contentView)
        progressView.align(.bottom, to: contentView)
        progressView.align(.top, to: contentView)
        progressViewRightConstraint = progressView.align(.right, to: contentView)
    }
    
    func setProgressView(ratio: CGFloat) {
        contentView.layoutIfNeeded()
        progressViewRightConstraint.constant = -((1 - ratio) * contentView.bounds.width)
        layoutIfNeeded()
    }
}
