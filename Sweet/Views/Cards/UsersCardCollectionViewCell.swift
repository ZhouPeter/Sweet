//
//  UsersCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol UsersCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    func showStoriesPlayerController(cell: UICollectionViewCell,
                                     storiesGroup: [[StoryCellViewModel]],
                                     currentIndex: Int,
                                     cardId: String?)
    
}

class UsersCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable  {
    
    func updateWith(_ viewModel: UsersCardViewModel) {
        cardId = viewModel.cardId
        self.viewModel = viewModel
        cellConfigurators.removeAll()
        viewModel.userContents.forEach { (viewModel) in
            let configurator = CellConfigurator<UserCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
        }
        collectionView.reloadData()
    }
    
    func updateItem(item: Int, like: Bool) {
        let cell = collectionView.cellForItem(at: IndexPath(row: item, section: 0))
        if let cell = cell as? UserCardCollectionViewCell {
            cell.update(like: like)
        }
    }
    
    typealias ViewModelType = UsersCardViewModel
    private var cellConfigurators = [CellConfiguratorType]()
    private var viewModel: UsersCardViewModel?
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
        collectionView.register(cellType: UserCardCollectionViewCell.self)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        customContent.addSubview(collectionView)
        collectionView.fill(in: customContent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UsersCardCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellConfigurators.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let configurator = cellConfigurators[indexPath.row] as? CellConfigurator<UserCardCollectionViewCell>  else { fatalError() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configurator.reuseIdentifier, for: indexPath)
        if let cell = cell as? UserCardCollectionViewCell { cell.delegate = self }
        cell.hero.isEnabled = true
        cell.hero.id = "\(configurator.viewModel.userId)" + (cardId ?? "")
        cell.hero.modifiers = [.arc]
        configurator.configure(cell)
        return cell
    }
}

extension UsersCardCollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let configurator = cellConfigurators[indexPath.row] as? CellConfigurator<UserCardCollectionViewCell>  else { fatalError() }
        if configurator.viewModel.type == .preference {
            let buddyID = configurator.viewModel.userId
            let setTop = SetTop(contentId: nil, preferenceId: configurator.viewModel.preferenceId)
            configurator.viewModel.showProfile?(buddyID, setTop)
            
        } else {
            guard let delegate = delegate as? UsersCardCollectionViewCellDelegate, let viewModel = self.viewModel else { return }
            let currentIndex = indexPath.row
            var index = 0
            var newCurrentIndex = currentIndex
            viewModel.userContents.forEach {
                if $0.type != .story && index < currentIndex {
                    newCurrentIndex -= 1
                }
                index += 1
            }
            let storyUserContents = viewModel.userContents.filter { return $0.type == .story }
            var storyUserContentsGroup = [[StoryCellViewModel]]()
            storyUserContents.forEach { storyUserContentsGroup.append( $0.storyViewModels!) }
            delegate.showStoriesPlayerController(cell: collectionView.cellForItem(at: indexPath)!,
                                                 storiesGroup: storyUserContentsGroup,
                                                 currentIndex: newCurrentIndex,
                                                 cardId: cardId)
        }
    
    }
}

extension UsersCardCollectionViewCell: UserCardCollectionViewCellDelegate {
    func showInputTextView(cell: UserCardCollectionViewCell) {
        if let viewModel = viewModel,
            let indexPath = collectionView.indexPath(for: cell),
            let activityId = viewModel.userContents[indexPath.row].activityId {
            viewModel.userContents[indexPath.row].callBack?(activityId)
        }
    }
    
    func showStoriesPlayerController(cell: UserCardCollectionViewCell) {
        if let delegate = delegate as? UsersCardCollectionViewCellDelegate,
            let viewModel = viewModel,
            let indexPath =  collectionView.indexPath(for: cell) {
            let currentIndex = indexPath.row
            var index = 0
            var newCurrentIndex = currentIndex
            viewModel.userContents.forEach {
                if $0.type != .story && index < currentIndex {
                    newCurrentIndex -= 1
                }
                index += 1
            }
            let storyUserContents = viewModel.userContents.filter { return $0.type == .story }
            var storyUserContentsGroup = [[StoryCellViewModel]]()
            storyUserContents.forEach { storyUserContentsGroup.append( $0.storyViewModels!) }
            delegate.showStoriesPlayerController(cell: cell,
                                                 storiesGroup: storyUserContentsGroup,
                                                 currentIndex: newCurrentIndex,
                                                 cardId: cardId)
        }
        
    }
}
