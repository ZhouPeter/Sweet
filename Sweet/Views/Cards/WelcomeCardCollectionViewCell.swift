//
//  WelcomeCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class WelcomeCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {

    typealias ViewModelType = WelcomeCardViewModel
    private var viewModel: ViewModelType?
    private lazy var centerImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Welcome"))
        return imageView
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private var contentLabels = [UILabel]()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        menuButton.isHidden = true
        let scale = UIScreen.mainWidth() / 375
        customContent.addSubview(centerImageView)
        centerImageView.align(.left, inset: 28 * scale)
        centerImageView.align(.right, inset: 28 * scale)
        centerImageView.align(.bottom, inset: 85 * scale)
        centerImageView.constrain(height: (UIScreen.mainWidth() -  38 * 2) * 4 / 3)
        centerImageView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 60 * scale, height: 60 * scale)
        avatarImageView.align(.top, inset: 65 * scale)
        avatarImageView.align(.left, inset: 30 * scale)
        avatarImageView.setViewRounded()
        centerImageView.addSubview(nameLabel)
        nameLabel.pin(.right, to: avatarImageView, spacing: 10 * scale)
        nameLabel.centerY(to: avatarImageView)
        addContents()
        customContent.addSubview(bottomLabel)
        bottomLabel.align(.left, inset: 80 * scale)
        bottomLabel.align(.right, inset: 80 * scale)
        bottomLabel.align(.bottom, inset: 12 * scale)
        bottomLabel.constrain(height: 50 * scale)
    }
    

    
    private func addContents() {
        let defaultSpacing: CGFloat = 25
        let scale = UIScreen.mainWidth() / 375
        for index in 0...2 {
            let spacing = defaultSpacing + CGFloat(80 * index) * scale
            let label = UILabel()
            label.textAlignment = .center
            label.backgroundColor = UIColor(hex: 0xD8D8D8)
            centerImageView.addSubview(label)
            label.align(.left, inset: 30 * scale)
            label.align(.right, inset: 30 * scale)
            label.pin(.bottom, to: avatarImageView, spacing: spacing)
            label.constrain(height: 60 * scale)
            label.layer.cornerRadius = 5 * scale
            label.clipsToBounds = true
            contentLabels.append(label)
        }
    }

    func updateWith(_ viewModel: WelcomeCardViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.titleString
        avatarImageView.sd_setImage(with: viewModel.avatarURL)
        let attributedString = NSMutableAttributedString(
            string: viewModel.nameString,
            attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black ])
        attributedString.addAttribute(.font,
                                      value: UIFont.boldSystemFont(ofSize: 20),
                                      range: NSRange(location: 0, length: viewModel.nicknameString.utf8.count))
        nameLabel.attributedText = attributedString
        for (index, label) in contentLabels.enumerated() {
            label.text = viewModel.contentStrings[index]
        }
        let bottomAttributedString = NSMutableAttributedString(
            string: viewModel.bottomString,
            attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black])
        bottomAttributedString.addAttribute(.font,
                                            value: UIFont.boldSystemFont(ofSize: 18),
                                            range: NSRange(location: 0, length: 11))
        bottomLabel.attributedText = bottomAttributedString
        
    }
    
}
