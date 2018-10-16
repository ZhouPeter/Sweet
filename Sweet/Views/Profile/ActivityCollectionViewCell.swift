//
//  ActivityCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ActivityCollectionViewCell: UICollectionViewCell {
    
    private var viewModel: PreferenceTextViewModel?
    private lazy var preferenceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var maskCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
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
        contentView.addSubview(preferenceImageView)
        preferenceImageView.fill(in: contentView)
        contentView.addSubview(maskCoverView)
        maskCoverView.fill(in: contentView)
        contentView.addSubview(titleLabel)
        titleLabel.align(.left)
        titleLabel.align(.right)
        titleLabel.align(.top, inset: 40)
        contentView.addSubview(likeButton)
        likeButton.centerX(to: contentView)
        likeButton.constrain(width: 30, height: 30)
        likeButton.align(.bottom, inset: 10)
        
    }
    
    @objc private func likeAction(_ sender: UIButton) {
        if let viewModel = viewModel, !viewModel.isLike {
            viewModel.callBack?(viewModel.activityId)
        }
    }
    
    func update(viewModel: PreferenceTextViewModel) {
        self.viewModel = viewModel
        preferenceImageView.sd_setImage(with: viewModel.imageURL)
        titleLabel.text = viewModel.textString
        likeButton.setImage(viewModel.isLike ? #imageLiteral(resourceName: "Like") : #imageLiteral(resourceName: "Unlike").withRenderingMode(.alwaysTemplate), for: .normal)
        likeButton.isHidden = viewModel.isHiddenLikeButton
    }
    
}
