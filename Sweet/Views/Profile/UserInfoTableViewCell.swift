//
//  UserInfoTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SDWebImage

protocol UserInfoTableViewCellDelegate: class {
    func didPressAvatarImageView(_ imageView: UIImageView, highURL: URL)
    func editSignature()
    func showLikeRankList()
}

class UserInfoTableViewCell: UITableViewCell {
    weak var delegate: UserInfoTableViewCellDelegate?
    private var viewModel: BaseInfoCellViewModel?
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressAvatar(_:)))
        imageView.addGestureRecognizer(tap)
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var sexImageView: UIImageView = UIImageView()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private lazy var heartImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Star")
        return imageView
    }()
    private lazy var starLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var contactLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var rankLabel: InsetLabel = {
        let label = InsetLabel()
        label.contentInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.backgroundColor = UIColor(hex: 0xF5A623)
        label.textColor = .white
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressRank(_:)))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var helpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.backgroundColor = UIColor(hex: 0xF5222D)
        label.textColor = .white
        label.text = "获❤️秘籍"
        label.textAlignment = .center
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressHelp(_:)))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    private lazy var segmentLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xf2f2f2)
        return view
    }()
    private lazy var segmentLineView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xf2f2f2)
        return view
    }()
    private lazy var collegeInfoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "CollegeInfo"), for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    private lazy var collegeInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = UIColor.black.withAlphaComponent(0.65)
        return label
    }()
    private lazy var signatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black.withAlphaComponent(0.65)
        return label
    }()
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Edit"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(didPressEdit(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xf2f2f2)
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        avatarImageView.align(.left, inset: 20)
        avatarImageView.align(.top, inset: 15)
        avatarImageView.constrain(width: 80, height: 80)
        contentView.addSubview(sexImageView)
        sexImageView.constrain(width: 16, height: 16)
        sexImageView.align(.right, to: avatarImageView, inset: 2)
        sexImageView.align(.bottom, to: avatarImageView, inset: 2)
        contentView.addSubview(nicknameLabel)
        nicknameLabel.pin(.right, to: avatarImageView, spacing: 16)
        nicknameLabel.align(.top, inset: 28)
        contentView.addSubview(starLabel)
        starLabel.align(.left, to: nicknameLabel)
        starLabel.pin(.bottom, to: nicknameLabel, spacing: 15)
        contentView.addSubview(heartImageView)
        heartImageView.constrain(width: 25, height: 25)
        heartImageView.centerY(to: starLabel)
        heartImageView.pin(.right, to: starLabel)
        contentView.addSubview(rankLabel)
        rankLabel.pin(.right, to: heartImageView, spacing: 6)
        rankLabel.pin(.top, to: heartImageView, spacing: -10)
        rankLabel.constrain(height: 20)
        contentView.addSubview(helpLabel)
        helpLabel.pin(.right, to: rankLabel, spacing: 6)
        helpLabel.centerY(to: rankLabel)
        helpLabel.constrain(width: 52, height: 20)
        helpLabel.setViewRounded(cornerRadius: 3)
        contentView.addSubview(contactLabel)
        contactLabel.centerY(to: starLabel)
        contactLabel.pin(.right, to: heartImageView)
        contentView.addSubview(segmentLineView)
        segmentLineView.align(.left)
        segmentLineView.align(.right)
        segmentLineView.constrain(height: 0.5)
        segmentLineView.pin(.bottom, to: avatarImageView, spacing: 15)
        contentView.addSubview(collegeInfoLabel)
        collegeInfoLabel.constrain(height: 40)
        collegeInfoLabel.align(.left, inset: 45)
        collegeInfoLabel.align(.right, inset: 10)
        collegeInfoLabel.pin(.bottom, to: segmentLineView)
        contentView.addSubview(collegeInfoButton)
        collegeInfoButton.fill(in: collegeInfoLabel, left: -22)
        
        contentView.addSubview(segmentLineView2)
        segmentLineView2.align(.left)
        segmentLineView2.align(.right)
        segmentLineView2.constrain(height: 0.5)
        segmentLineView2.pin(.bottom, to: collegeInfoLabel)
        
        contentView.addSubview(signatureLabel)
        signatureLabel.constrain(height: 40)
        signatureLabel.align(.left, inset: 45)
        signatureLabel.align(.right, inset: 10)
        signatureLabel.pin(.bottom, to: segmentLineView2)
        contentView.addSubview(editButton)
        editButton.fill(in: signatureLabel, left: -22)
        contentView.addSubview(bottomMaskView)
        bottomMaskView.align(.left)
        bottomMaskView.align(.right)
        bottomMaskView.align(.bottom)
        bottomMaskView.constrain(height: 8)
    }
    
    func updateWith(_ viewModel: BaseInfoCellViewModel) {
        self.viewModel = viewModel
        avatarImageView.sd_setImage(with: viewModel.avatarImageURL)
        sexImageView.image = viewModel.sexImage
        nicknameLabel.text = viewModel.nicknameString
        starLabel.text = viewModel.starString
        contactLabel.text = viewModel.contactString
        collegeInfoLabel.text = viewModel.collegeInfoString
        signatureLabel.text = viewModel.signatureString
        if viewModel.isLoginUser {
            rankLabel.isHidden = false
            helpLabel.isHidden = false
            if viewModel.rankString == "" {
                rankLabel.isHidden = true
            } else {
                rankLabel.text = viewModel.rankString
            }
            
        } else {
            rankLabel.isHidden = true
            helpLabel.isHidden = true
        }
        
    }
    
    @objc private func didPressAvatar(_ tap: UITapGestureRecognizer) {
        delegate?.didPressAvatarImageView(avatarImageView, highURL: viewModel!.avatarImageURL)
    }
    
    @objc private func didPressEdit(_ sender: UIButton) {
        if let viewModel = viewModel, viewModel.isLoginUser {
            delegate?.editSignature()
        }
    }
    @objc private func didPressHelp(_ tap: UITapGestureRecognizer) {
        Guide.showGetStarHelpMessage()
    }
    
    @objc private func didPressRank(_ tap: UITapGestureRecognizer) {
        delegate?.showLikeRankList()
    }
}
