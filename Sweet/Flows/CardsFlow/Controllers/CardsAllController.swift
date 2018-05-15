//
//  CardsController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol CardsAllView: BaseView {
    
}
let cardCellHeight: CGFloat = UIScreen.mainWidth() * 1.5
class CardsAllController: BaseViewController, CardsAllView {
    private var cellConfigurators = [CellConfiguratorType]()
    private var cards = [CardResponse]()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.bounds.width, height: cardCellHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset.top = 10
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: ContentCardCollectionViewCell.self)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpGray()
        view.addSubview(collectionView)
        collectionView.fill(in: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startLoadCards()
    }
    private func startLoadCards() {
        web.request(.allCards, responseType: Response<CardListResponse>.self) { (result) in
            switch result {
            case let .success(response):
                response.list.forEach({ (card) in
                    self.cards.append(card)
                    self.appendConfigurator(card: card)
                })
                self.collectionView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func appendConfigurator(card: CardResponse) {
        switch card.type {
        case .content:
            let viewModel = ContentCardViewModel(model: card)
            let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
        default: break
        }
        
    }
}

extension CardsAllController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellConfigurators.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let configurator = cellConfigurators[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configurator.reuseIdentifier, for: indexPath)
        configurator.configure(cell)
        return cell
    }
}

extension CardsAllController: UICollectionViewDelegate {
    
}
