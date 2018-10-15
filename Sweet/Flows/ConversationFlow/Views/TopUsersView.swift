//
//  TopUsersView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/10/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class TopUserCell: UICollectionViewCell {
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.center(to: contentView)
        avatarImageView.setViewRounded(borderWidth: 2, borderColor: .white)
    }
    
    func updateWith(_ avatarURL: URL) {
        avatarImageView.sd_setImage(with: avatarURL)
    }
}

class TopUsersView: UIView {
    var showProfile: ((UInt64) -> Void)?
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let attributedString = NSMutableAttributedString(string: "当日活跃\nTOP5")
        attributedString.addAttributes([.foregroundColor: UIColor.black], range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 17)], range: NSRange(location: 0, length: 4))
        attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], range: NSRange(location: 5, length: 4))
        label.attributedText = attributedString
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = 40 + 12
        layout.itemSize = CGSize(width: width, height: width)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TopUserCell.self, forCellWithReuseIdentifier: "TopUserCell")
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var userRankingList = [UserRankingResponse]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func update(userRankingList: [UserRankingResponse]) {
        self.userRankingList = userRankingList
        collectionView.reloadData()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.align(.left, inset: 14)
        titleLabel.constrain(width: 72)
        titleLabel.centerY(to: self)
        addSubview(collectionView)
        collectionView.pin(.right, to: titleLabel, spacing: 14)
        collectionView.align(.right)
        collectionView.align(.top, inset: 6)
        collectionView.align(.bottom, inset: 6)
    }
}
extension TopUsersView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userRankingList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TopUserCell",
            for: indexPath) as? TopUserCell  else {  fatalError() }
        cell.updateWith(URL(string: userRankingList[indexPath.row].avatar)!)
        return cell
    }
}

extension TopUsersView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showProfile?(userRankingList[indexPath.row].userId)
    }
}
