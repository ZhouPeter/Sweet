//
//  StoriesCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol StoriesCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    func showStoriesPlayerController(storiesGroup: [[StoryCellViewModel]], currentIndex: Int)
}
class StoriesCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    
    private var cellConfigurators = [CellConfiguratorType]()
    private var storiesGroup = [[StoryCellViewModel]]()
    func updateWith(_ viewModel: StoriesCardViewModel) {
        cellConfigurators.removeAll()
//        viewModel.storiesCellModels.forEach { (viewModels) in
//            let firstViewModel = viewModels[0]
//            let configurator = CellConfigurator<StoryCardCollectionViewCell>(viewModel: firstViewModel)
//            cellConfigurators.append(configurator)
//        }
//        for (index, viewModels) in viewModel.storiesCellModels.enumerated() {
//            var firstViewModel = viewModels[0]
//            firstViewModel.isRead = viewModel.isReads[index]
//            let configurator = CellConfigurator<StoryCardCollectionViewCell>(viewModel: firstViewModel)
//            cellConfigurators.append(configurator)
//
//        }
        viewModel.storyCellModels.forEach { (cellModel) in
            let configurator = CellConfigurator<StoryCardCollectionViewCell>(viewModel: cellModel)
            cellConfigurators.append(configurator)
        }
        storiesGroup = viewModel.storiesGroup
        collectionView.reloadData()
    }
    
    typealias ViewModelType = StoriesCardViewModel
    
    private lazy var collectionView: UICollectionView = {
        let itemWidth = (UIScreen.mainWidth() - 20 * 2 - 5) / 2
        let itemHeight = (cardCellHeight - 20 * 2 - 10) / 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing  = 5
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: StoryCardCollectionViewCell.self)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        customContent.addSubview(collectionView)
        collectionView.fill(in: customContent)
    }
}

extension StoriesCardCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellConfigurators.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let configurator = cellConfigurators[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configurator.reuseIdentifier, for: indexPath)
        configurator.configure(cell)
        return cell
    }
}

extension StoriesCardCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate as? StoriesCardCollectionViewCellDelegate {
            delegate.showStoriesPlayerController(storiesGroup: storiesGroup,
                                                 currentIndex: indexPath.item)
        }
    }
}
