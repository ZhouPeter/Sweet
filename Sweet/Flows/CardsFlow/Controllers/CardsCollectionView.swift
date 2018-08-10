//
//  CardsCollectionView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
let cardCellHeight: CGFloat = UIScreen.mainWidth() * 1.5
let cardOffset: CGFloat = 10
class CardsCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.mainWidth(), height: cardCellHeight)
        self.init(frame: .zero, collectionViewLayout: layout)
        keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        contentInset.top = cardOffset
        contentInset.bottom = UIScreen.mainHeight() - cardCellHeight - cardOffset - UIScreen.navBarHeight()
        backgroundColor = .clear
        isScrollEnabled = false
        register(cellType: ContentCardCollectionViewCell.self)
        register(cellType: VideoCardCollectionViewCell.self)
        register(cellType: ChoiceCardCollectionViewCell.self)
        register(cellType: EvaluationCardCollectionViewCell.self)
        register(cellType: ActivitiesCardCollectionViewCell.self)
        register(cellType: StoriesCardCollectionViewCell.self)
        register(cellType: LongTextCardCollectionViewCell.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
