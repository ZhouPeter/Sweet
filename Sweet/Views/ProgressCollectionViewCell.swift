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
        let frame = contentView.bounds
        progressView.frame = frame
    }
    
    func setProgressView(ratio: CGFloat) {
        layoutIfNeeded()
        var frame = bounds
        frame.size.width = frame.width * ratio
        progressView.frame = frame
    }
}
