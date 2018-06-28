//
//  StoriesCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol StoriesCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    func showStoriesPlayerController(cell: UICollectionViewCell,
                                     storiesGroup: [[StoryCellViewModel]],
                                     currentIndex: Int,
                                     cardId: String?)
}
class StoriesCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    
    private var cellConfigurators = [CellConfiguratorType]()
    private var storiesGroup = [[StoryCellViewModel]]()
    func updateWith(_ viewModel: StoriesCardViewModel) {
        cardId = viewModel.cardId
        cellConfigurators.removeAll()
        viewModel.storyCellModels.forEach { (cellModel) in
            let configurator = CellConfigurator<StoryCardCollectionViewCell>(viewModel: cellModel)
            cellConfigurators.append(configurator)
        }
        storiesGroup = viewModel.storiesGroup
        collectionView.reloadData()
    }
    
    typealias ViewModelType = StoriesCardViewModel
    
    lazy var collectionView: UICollectionView = {
        let itemWidth = (UIScreen.mainWidth() - 15 * 2 - 3) / 2
        let itemHeight = (cardCellHeight - 15 * 2 - 3) / 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
        cell.hero.isEnabled = true
        cell.hero.id = "\(storiesGroup[indexPath.row][0].userId)" + (cardId ?? "")
        cell.hero.modifiers = [.arc]
        configurator.configure(cell)
        return cell
    }
}

extension StoriesCardCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate as? StoriesCardCollectionViewCellDelegate {
            delegate.showStoriesPlayerController(cell: collectionView.cellForItem(at: indexPath)!,
                                                 storiesGroup: storiesGroup,
                                                 currentIndex: indexPath.item,
                                                 cardId: cardId)
        }
    }
}
