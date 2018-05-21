//
//  CardsBaseController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/17.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
let cardCellHeight: CGFloat = UIScreen.mainWidth() * 1.5

class CardsBaseController: BaseViewController {
    public var index = 0
    public var panPoint: CGPoint?
    public var panOffset: CGPoint?
    public let offset: CGFloat = UIScreen.navBarHeight() + 10
    public var cellConfigurators = [CellConfiguratorType]()
    public var cards = [CardResponse]()
    public lazy var collectionView: UICollectionView = {
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
        collectionView.register(cellType: ChoiceCardCollectionViewCell.self)
        collectionView.register(cellType: EvaluationCardCollectionViewCell.self)
        collectionView.register(cellType: ActivitiesCardCollectionViewCell.self)
        collectionView.register(cellType: StoriesCardCollectionViewCell.self)
        collectionView.addGestureRecognizer(
            PanGestureRecognizer(direction: .vertical, target: self, action: #selector(didPan(_:)))
        )
        return collectionView
    }()
    
    lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "说点有意思的"
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpGray()
        view.addSubview(collectionView)
        collectionView.fill(in: view)
    }

}
// MARK: - Actions
extension CardsBaseController {
    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: nil)
        if gesture.state == .began {
            panPoint = point
            panOffset = collectionView.contentOffset
        } else if gesture.state == .changed {
            guard index > 0 else { return }
            guard let start = panPoint, var offset = panOffset else { return }
            let translation = point.y - start.y
            offset.y -= translation
            collectionView.contentOffset = offset
        } else {
            scrollCard(withPoint: point)
        }
    }
}
// MARK: - Publics
extension CardsBaseController {
    func scrollCard(withPoint point: CGPoint) {
        guard let start = panPoint else { return }
        if point.y < start.y {
            guard index < collectionView.numberOfItems(inSection: 0) - 1 else {
                self.scrollTo(row: index)
                return
            }
            index += 1
        } else {
            guard index > 0  else { return }
            index -= 1
        }
        self.scrollTo(row: index)
    }
    
    func scrollTo(row: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let offset: CGFloat =  CGFloat(row) * cardCellHeight - self.offset
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.collectionView.contentOffset.y = offset
            }, completion: nil)
        }
    }
    
    func appendConfigurator(card: CardResponse) {
        switch card.type {
        case .content:
            let viewModel = ContentCardViewModel(model: card)
            let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
        case .choice:
            let viewModel = ChoiceCardViewModel(model: card)
            let configurator = CellConfigurator<ChoiceCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
        case .evaluation:
            let viewModel = EvaluationCardViewModel(model: card)
            let configurator = CellConfigurator<EvaluationCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
        case .activity:
            var viewModel = ActivitiesCardViewModel(model: card)
            for(offset, var activityViewModel) in viewModel.activityViewModels.enumerated() {
                activityViewModel.callBack = { activityItemId in
                    self.showInputView(activityItemId: activityItemId)
                }
                viewModel.activityViewModels[offset] = activityViewModel
            }
            let configurator = CellConfigurator<ActivitiesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
        case .story:
            let viewModel = StoriesCardViewModel(model: card)
            let configurator = CellConfigurator<StoriesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
        default: break
        }
        
    }
    
    private func showInputView(activityItemId: String) {
        let window = UIApplication.shared.windows.last!
        window.addSubview(inputTextView)
        inputTextView.fill(in: window)
        inputTextView.startEditing(isStarted: true)
    }
}

extension CardsBaseController: InputTextViewDelegate {
    func inputTextViewDidPressSendMessage(text: String) {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
        toast(message: "❤️ 评价成功")
    }
    
    func removeInputTextView() {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
    }
    
}

extension CardsBaseController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellConfigurators.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let configurator = cellConfigurators[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configurator.reuseIdentifier, for: indexPath)
        configurator.configure(cell)
        if let cell = cell as? BaseCardCollectionViewCell {
            cell.delegate = self
        }
        return cell
    }
}

extension CardsBaseController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playVC = PlayController()
        self.present(playVC, animated: true, completion: nil)
        let newIndex = indexPath.row
        guard newIndex != index else { return }
        index = newIndex
        scrollTo(row: index)
    }
}

extension CardsBaseController: BaseCardCollectionViewCellDelegate {
    func showAlertController(cardId: String, fromCell: BaseCardCollectionViewCell) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "分享给好友", style: .default) { (_) in
            
        }
        let subscriptionAction = UIAlertAction(title: "订阅", style: .default) { (_) in
            
        }
        let unlikeAction = UIAlertAction(title: "不感兴趣", style: .default) { (_) in
            
        }
        let reportAction = UIAlertAction(title: "举报", style: .destructive) { (_) in
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(shareAction)
        alertController.addAction(subscriptionAction)
        alertController.addAction(unlikeAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
