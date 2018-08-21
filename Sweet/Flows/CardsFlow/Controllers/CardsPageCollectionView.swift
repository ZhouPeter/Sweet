//
//  CardsPageCollectionView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
protocol CardsPageCollectionViewDataSource: NSObjectProtocol {
    func cardsPageCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func cardsPageCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}
protocol CardsPageCollectionViewDelegate: NSObjectProtocol {
    func cardsPageCollectionView(_ collectionView: UICollectionView, scrollToIndex index:Int)
    func cardsPageCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}
class CardsPageCollectionView: UIView {
    let collectionView: UICollectionView
    private let flowLayout = UICollectionViewFlowLayout()
    private var itemSize = CGSize.zero
    private let pagingScrollView = UIScrollView()
    private var oldScrollViewOffset = CGPoint.zero
    weak var dataSoure: CardsPageCollectionViewDataSource?
    weak var delegate: CardsPageCollectionViewDelegate?
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        super.init(frame: .zero)
        backgroundColor = UIColor.xpGray()
        setupCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollToIndex(_ index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let offset: CGFloat =  CGFloat(index) * cardCellHeight - cardInsetTop
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.collectionView.contentOffset.y = offset
            }, completion: nil)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.fill(in: self)
        let width = collectionView.bounds.width
        let height = width * 1.5
        itemSize = CGSize(width: width, height: height)
        pagingScrollView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: itemSize.height)
        pagingScrollView.contentInset.top = cardInsetTop
        updatePageContentSize()
    }
    func updatePageContentSize() {
        let count = collectionView.numberOfItems(inSection: 0)
        let height = CGFloat(count) * itemSize.height
        pagingScrollView.contentSize = CGSize(width: itemSize.width, height: height)
    }
    private func setupCollectionView() {
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        addSubview(collectionView)
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        collectionView.contentInset.top = cardInsetTop
        collectionView.contentInset.bottom = UIScreen.mainHeight() - cardCellHeight - cardInsetTop - UIScreen.navBarHeight()
        collectionView.backgroundColor = .clear
        collectionView.register(cellType: ContentCardCollectionViewCell.self)
        collectionView.register(cellType: VideoCardCollectionViewCell.self)
        collectionView.register(cellType: ChoiceCardCollectionViewCell.self)
        collectionView.register(cellType: EvaluationCardCollectionViewCell.self)
        collectionView.register(cellType: ActivitiesCardCollectionViewCell.self)
        collectionView.register(cellType: StoriesCardCollectionViewCell.self)
        collectionView.register(cellType: LongTextCardCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(pagingScrollView)
        pagingScrollView.isHidden = true
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.delegate = self
        collectionView.addGestureRecognizer(pagingScrollView.panGestureRecognizer)
        collectionView.panGestureRecognizer.isEnabled = false
    }
    
    

}

extension CardsPageCollectionView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return dataSoure!.cardsPageCollectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSoure!.cardsPageCollectionView(collectionView, cellForItemAt: indexPath)
    }

}

extension CardsPageCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate!.cardsPageCollectionView(collectionView, didSelectItemAt: indexPath)
    }
}

extension CardsPageCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
}

extension CardsPageCollectionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == pagingScrollView else { return }
        var scrollViewOffset = scrollView.contentOffset
        if scrollViewOffset.y >= 0 { scrollViewOffset.y -= cardInsetTop }
        var pageIndex = Int((scrollViewOffset.y + cardInsetTop) / cardCellHeight + 0.5)
        if pageIndex == collectionView.numberOfItems(inSection: 0) - 1 &&
            scrollViewOffset.y > oldScrollViewOffset.y {
            pageIndex += 1
        }
        delegate?.cardsPageCollectionView(collectionView, scrollToIndex: pageIndex)
        collectionView.contentOffset = scrollViewOffset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == pagingScrollView else { return }
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop { scrollViewDidEndScroll(scrollView) }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == pagingScrollView else { return }
        let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if dragToDragStop { scrollViewDidEndScroll(scrollView) }

    }
    
    func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        oldScrollViewOffset = scrollView.contentOffset
    }

}
