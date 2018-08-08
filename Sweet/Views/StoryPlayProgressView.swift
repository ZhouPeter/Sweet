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
    private let itemSpace: CGFloat = 1

    private lazy var collectionView: UICollectionView = {
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = itemSpace
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
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
    
    func reset(count: Int, index: Int) {
        self.count = count
        self.index = index
        self.ratio = 0
        collectionView.reloadData()
//        collectionView.performBatchUpdates(nil) { (_) in
//            for cell in self.collectionView.visibleCells {
//                if let cell  = cell as? ProgressCollectionViewCell {
//                    cell.setProgressView(ratio: 0)
//                }
//            }
//        }
    }
    
    private func setupUI() {
        addSubview(collectionView)
        collectionView.fill(in: self)
    }
    
    func setProgress(ratio: CGFloat, index: Int) {
        self.index = index
        let indexPath = IndexPath(row: index, section: 0)
        self.ratio = ratio
        DispatchQueue.main.async { [weak self] in
            let cell = self?.collectionView.cellForItem(at: indexPath) as? ProgressCollectionViewCell
            cell?.setProgressView(ratio: ratio)
        }
    }
    
    func setProgress(selectedIndex: Int) {
        self.index = selectedIndex
    }
    
    private func setCollectionViewCells(currentIndex: Int) {
        for row in 0..<count {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
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
extension StoryPlayProgressView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = (UIScreen.mainWidth() - CGFloat(count - 1) * itemSpace) / CGFloat(count)
        let itemHeight: CGFloat = 2
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
