//
//  SourceInfoView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
class SourceInfoView: UIView {
    private lazy var sourceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var briefLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 0, alpha: 0.5)
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(backgroundView)
        backgroundView.fill(in: self)
        addSubview(sourceImageView)
        sourceImageView.align(.left)
        sourceImageView.align(.bottom)
        sourceImageView.align(.top)
        sourceImageView.widthAnchor.constraint(equalTo: sourceImageView.heightAnchor, multiplier: 1).isActive = true
        addSubview(titleLabel)
        titleLabel.pin(.right, to: sourceImageView, spacing: 8)
        titleLabel.align(.right)
        titleLabel.align(.top, inset: 16)
        addSubview(briefLabel)
        briefLabel.pin(.right, to: sourceImageView, spacing: 8)
        briefLabel.align(.right)
        briefLabel.align(.bottom, inset: 16)
    }
    
    func update(thumbnailURL: URL?, title: String, brief: String?) {
        if let thumbnailURL = thumbnailURL {
            sourceImageView.isHidden = false
            sourceImageView.kf.setImage(with: thumbnailURL)
        } else {
            sourceImageView.isHidden = true
        }
        titleLabel.text = title
        briefLabel.text = brief ?? ""
        if briefLabel.text == "" {
            titleLabel.numberOfLines = 2
        } else {
            titleLabel.numberOfLines = 1
        }
    }
}
