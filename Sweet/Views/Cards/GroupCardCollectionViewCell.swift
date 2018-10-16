//
//  GroupCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/10/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol GroupCardCollectionViewCellDelegate: NSObjectProtocol {
    func joinGroup(groupId: UInt64, cardId: String)
}
class GroupCardCollectionViewCell: BaseCardCollectionViewCell, CellUpdatable, CellReusable {
    typealias ViewModelType = GroupCardViewModel
    private var viewModel: ViewModelType?
    func updateWith(_ viewModel: GroupCardViewModel) {
        titleLabel.textColor = .white
        self.viewModel = viewModel
        backgroundImageView.sd_setImage(with: viewModel.backgroudImageURL)
        titleLabel.text = viewModel.titleString
        groupTitleLabel.text = viewModel.groupTitle
        avatarImageViews.forEach { $0.isHidden = true }
        for (index, url) in viewModel.avatarURLs.prefix(3).enumerated() {
            avatarImageViews[index].isHidden = false
            avatarImageViews[index].sd_setImage(with: url, placeholderImage: nil)
        }
        joinGroupButton.setTitle(viewModel.buttonTitleString, for: .normal)
    }
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var backgroundMaskImageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return view
    }()
    private lazy var groupTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "这些人也在群聊中\n👇👇👇"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Help"), for: .normal)
        button.addTarget(self, action: #selector(didPressHelp(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    private lazy var joinGroupButton: UIButton = {
        let button = UIButton()
        button.setTitle("加入群聊", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        button.addTarget(self, action: #selector(didPressJoin(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        return button
    }()
    
    private var avatarImageViews = [UIImageView]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didPressHelp(_ sender: UIButton) {
        Guide.showGroupHelpMessage()
        CardAction.clickHelp.actionLog(cardId: viewModel!.cardId)
    }
    
    @objc private func didPressJoin(_ sender: UIButton) {
        if let delegate = delegate as? GroupCardCollectionViewCellDelegate {
            delegate.joinGroup(groupId: viewModel!.groupId, cardId: viewModel!.cardId)
        }
    }
    
    func updateButtonString(joinGroupButtonString: String?){
        joinGroupButton.setTitle(joinGroupButtonString, for: .normal)
    }
    
    private func setupUI() {
        let scale = UIScreen.mainWidth() / 375
        customContent.insertSubview(backgroundImageView, belowSubview: titleLabel)
        backgroundImageView.fill(in: customContent)
        backgroundImageView.addSubview(backgroundMaskImageView)
        backgroundMaskImageView.fill(in: backgroundImageView)
        customContent.addSubview(helpButton)
        helpButton.centerY(to: titleLabel)
        helpButton.align(.right, to: customContent, inset: 10)
        helpButton.constrain(width: 40, height: 40)
        customContent.addSubview(groupTitleLabel)
        groupTitleLabel.align(.top, inset: 120 * scale)
        groupTitleLabel.centerX(to: customContent)
        customContent.addSubview(subTitleLabel)
        subTitleLabel.pin(.bottom, to: groupTitleLabel, spacing: 35 * scale)
        subTitleLabel.centerX(to: customContent)
        setAvatarImageViews()
        
        customContent.addSubview(joinGroupButton)
        joinGroupButton.align(.left, inset: 40)
        joinGroupButton.align(.right, inset: 40)
        joinGroupButton.align(.bottom, inset: 60 * scale)
        joinGroupButton.constrain(height: 85)
    }
    
    private func setAvatarImageViews() {
        for index in 0...2 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            customContent.addSubview(imageView)
            imageView.constrain(width: 70, height: 70)
            imageView.centerX(to: customContent, offset: CGFloat(index - 1) * 90)
            imageView.pin(.bottom, to: subTitleLabel, spacing: 18)
            imageView.setViewRounded(borderWidth: 2, borderColor: .white)
            imageView.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(didPressAvatar(_:)))
            imageView.addGestureRecognizer(tap)
            imageView.isUserInteractionEnabled = true
            avatarImageViews.append(imageView)
        }
    }
    
    
    @objc private func didPressAvatar(_ tap: UITapGestureRecognizer) {
        if let index = tap.view?.tag, let buddyID = viewModel?.members[index] {
            viewModel?.showProfile?(buddyID)
        }
    }
    
    
}
