//
//  StoryPlayProgressView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class StoryPlayProgressView: UIView {
    
    private var index: Int {
        didSet {
            if oldValue != index {
                self.setCollectionViewCells(currentIndex: index)
            }
        }
    }
    private var count: Int
    private var ratio: CGFloat = 0
    
    private var layout: UICollectionViewFlowLayout!
    private lazy var collectionView: UICollectionView = {
        let itemSpace: CGFloat = 0.5
        let itemWidth: CGFloat = (UIScreen.mainWidth() - CGFloat(count - 1) * itemSpace) / CGFloat(count)
        let itemHeight: CGFloat = 2
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = itemSpace
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(ProgressCollectionViewCell.self, forCellWithReuseIdentifier: "progressCell")
        return collectionView

    }()
    
    init(count: Int, index: Int) {
        self.count = count
        self.index = index
        super.init(frame: .zero)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(collectionView)
        collectionView.fill(in: self)
    }
    
    func setProgress(ratio: CGFloat, index: Int) {
        self.index = index
        let indexPath = IndexPath(row: index, section: 0)
        self.ratio = ratio
        DispatchQueue.main.async {
            let cell = self.collectionView.cellForItem(at: indexPath) as? ProgressCollectionViewCell
            cell?.setProgressView(ratio: ratio)
        }
    }
    
    func setProgress(selectedIndex: Int) {
        self.index = selectedIndex
    }
    
    private func setCollectionViewCells(currentIndex: Int) {
        for row in 0..<count {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                let cell = self.collectionView.cellForItem(at: indexPath) as? ProgressCollectionViewCell
                if  row < self.index {
                    cell?.setProgressView(ratio: 1)
                } else {
                    cell?.setProgressView(ratio: 0)
                }
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension StoryPlayProgressView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                                        withReuseIdentifier: "progressCell",
                                        for: indexPath) as? ProgressCollectionViewCell else { fatalError() }
        if indexPath.row < index {
            cell.setProgressView(ratio: 1)
        } else if indexPath.row == index {
            cell.setProgressView(ratio: ratio)
        } else {
            cell.setProgressView(ratio: 0)
        }
        
        return cell
    }
}
