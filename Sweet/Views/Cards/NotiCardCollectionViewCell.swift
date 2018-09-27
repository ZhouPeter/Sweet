//
//  NotiCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class RankingView: UIView {
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = "查看实时排名👉"
        return label
    }()
    private var storage: Storage?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        if let IDString = Defaults[.userID], let userID = UInt64(IDString) {
            storage = Storage(userID: userID)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(avatarImageView)
        avatarImageView.constrain(width: 60, height: 60)
        avatarImageView.centerY(to: self)
        avatarImageView.align(.left, inset: 33)
        avatarImageView.setViewRounded(borderWidth: 1, borderColor: .white)
        addSubview(titleLabel)
        titleLabel.pin(.right, to: avatarImageView, spacing: 20)
        titleLabel.align(.top, to: avatarImageView)
        addSubview(subTitleLabel)
        subTitleLabel.align(.left, to: titleLabel)
        subTitleLabel.align(.bottom, to: avatarImageView)
    }
    
    func update(changeType: RankChangeType) {
        storage?.read({ [weak self] (realm) in
            guard let `self` = self else { return }
            guard let user = realm.object(ofType: UserData.self, forPrimaryKey: self.storage!.userID) else { return }
            let avatarURL = URL(string: user.avatarURLString)
            DispatchQueue.main.async {
                self.avatarImageView.sd_setImage(with: avatarURL)
            }
        })
        if changeType == .up {
            titleLabel.text = "你的排名上升了"
        } else if changeType == .down {
            titleLabel.text = "你的排名下降了"
        } else {
            titleLabel.text = "你的排名没有变化"

        }
    }
    
    
}
class NotiCardCollectionViewCell: BaseCardCollectionViewCell, CellUpdatable, CellReusable {
    typealias ViewModelType = NotiCardViewModel
    private var viewModel: ViewModelType?
    func updateWith(_ viewModel: NotiCardViewModel) {
        self.viewModel = viewModel
        titleLabel.textColor = .white
        titleLabel.text = viewModel.titleString
        rankingView.update(changeType: viewModel.changeType)
        collectionView.reloadData()
        
    }
    
    private lazy var colorBackgroudImageView: UIImageView = {
        let image = MakeImager.gradientImage(bounds: CGRect(x: 0,
                                                            y: 0,
                                                            width: UIScreen.mainWidth() - 20,
                                                            height: cardCellHeight),
                                             colors: [UIColor(hex: 0xC32AFF), UIColor(hex: 0x9013FE)])
        let imageView = UIImageView(image: image)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.mainWidth() - 40, height: 60)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(NotiRankingCollectionViewCell.self, forCellWithReuseIdentifier: "rankingCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Help"), for: .normal)
        button.addTarget(self, action: #selector(didPressHelp(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var rankingView: RankingView = {
        let view = RankingView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        view.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressRanking(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didPressRanking(_ tap: UITapGestureRecognizer) {
        viewModel?.showRankingList?()
    }
    @objc private func didPressHelp(_ sender: UIButton) {
        Guide.showLikeRankHelpMessage()
    }
    private func setupUI() {
        menuButton.isHidden = true
        customContent.insertSubview(colorBackgroudImageView, belowSubview: titleLabel)
        colorBackgroudImageView.fill(in: customContent)
        customContent.addSubview(collectionView)
        collectionView.align(.left, inset: 10)
        collectionView.align(.right, inset: 10)
        collectionView.pin(.bottom, to: titleLabel, spacing: 15)
        collectionView.constrain(height: 60 * 5 + 10 * 4)
        customContent.addSubview(rankingView)
        rankingView.align(.left, inset: 10)
        rankingView.align(.right, inset: 10)
        rankingView.align(.bottom, inset: 10)
        rankingView.pin(.bottom, to: collectionView, spacing: 10)
        customContent.addSubview(helpButton)
        helpButton.centerY(to: titleLabel)
        helpButton.align(.right, to: customContent, inset: 10)
        helpButton.constrain(width: 20, height: 20)
    }
}

extension NotiCardCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.likeRankViewModels[indexPath.row].showProfile?(viewModel!.likeRankViewModels[indexPath.row].userId, nil)
    }
}

extension NotiCardCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "rankingCell",
                    for: indexPath) as? NotiRankingCollectionViewCell else { fatalError() }
        guard let viewModel = viewModel else { fatalError() }
        cell.update(viewModel: viewModel.likeRankViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.likeRankViewModels.count
    }
}
