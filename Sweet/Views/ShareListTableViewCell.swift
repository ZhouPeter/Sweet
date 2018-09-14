//
//  ShareListTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ShareListTableViewCellDelegate: NSObjectProtocol {
    func didSelectItemAt(index: Int)
}
class ShareListTableViewCell: UITableViewCell {

    var imageList = [UIImage]()
    weak var delegate: ShareListTableViewCellDelegate?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ShareCollectionViewCell.self, forCellWithReuseIdentifier: "shareCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(collectionView)
        collectionView.fill(in: contentView)
    }
    
    func update(images: [UIImage]) {
        imageList = images
        collectionView.reloadData()
    }
    
}

extension ShareListTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "shareCell",
            for: indexPath) as? ShareCollectionViewCell  else { fatalError() }
        cell.update(image: imageList[indexPath.item])
        return cell
    }
}

extension ShareListTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainWidth() / CGFloat(imageList.count), height: frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAt(index: indexPath.item)
    }
}
