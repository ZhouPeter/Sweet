//
//  CardsBaseController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/17.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation
import JXPhotoBrowser
import SwiftyUserDefaults

enum Direction: Int {
    case unknown = 0
    case up = 1
    case down = 2
    case recover = 3
}
enum CardRequst {
    case all(cardId: String?, direction: Int?)
    case sub(cardId: String?, direction: Int?)
}
let cardCellHeight: CGFloat = UIScreen.mainWidth() * 1.5

class CardsBaseController: BaseViewController {
    private var delayItem: DispatchWorkItem?
    private lazy var inputBottomView: InputBottomView = {
        let view = InputBottomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.shouldSendNilText = true
        view.placeHolder = "说点什么..."
        view.maxLength = 50
        return view
    } ()
    
    public var index = 0 {
        didSet {
            let oldIndexPath = IndexPath(item: oldValue, section: 0)
            guard let oldCell = collectionView.cellForItem(at: oldIndexPath) else { return }
            if let oldCell = oldCell as? ContentCardCollectionViewCell {
                oldCell.resetEmojiView()
            }
        }
    }
    public var panPoint: CGPoint?
    public var panOffset: CGPoint?
    public let offset: CGFloat = 10
    public var cellConfigurators = [CellConfiguratorType]() {
        didSet {
            if self is CardsSubscriptionController {
                showEmptyView(isShow: cellConfigurators.count == 0)
            }
        }
    }
    public var cards = [CardResponse]()
    private var pan: PanGestureRecognizer!
    private var cotentOffsetToken: NSKeyValueObservation?

    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.bounds.width, height: cardCellHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
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
        pan = PanGestureRecognizer(direction: .vertical, target: self, action: #selector(didPan(_:)))
        pan.delegate = self
        collectionView.addGestureRecognizer(pan)
        cotentOffsetToken = collectionView.observe(\.contentOffset, options: .new, changeHandler: { (object, _) in
            if object.contentOffset.y + self.offset  == CGFloat(self.index) * cardCellHeight {
                self.delayItem?.cancel()
                if self.cellConfigurators.count == 0 { return }
                let indexPath = IndexPath(item: self.index, section: 0)
                let configurator = self.cellConfigurators[self.index]
                guard let cell = collectionView.cellForItem(at: indexPath) else { return }
                if let cell = cell as? ContentCardCollectionViewCell,
                    let configurator = configurator as? CellConfigurator<ContentCardCollectionViewCell> {
                    if let videoURL = configurator.viewModel.videoURL {
                        weak var weakSelf = self
                        weak var weakCell = cell
                        let resource = SweetPlayerResource(url: videoURL)
                        resource.indexPath = indexPath
                        resource.scrollView = weakSelf?.collectionView
                        resource.fatherViewTag = weakCell?.contentImageView.tag
                        self.playerView.setVideo(resource: resource)
                        self.avPlayer = self.playerView.avPlayer
                    }
                    self.delayItem = DispatchWorkItem {
                        cell.emojiView.isHidden = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: self.delayItem!)
                }
            }
        })
        return collectionView
    }()
    
    private lazy var emptyView: EmptyEmojiView = {
        let view = EmptyEmojiView()
        view.titleLabel.text = "快去首页订阅有趣的内容"
        return view
    }()
    private lazy var playerView: SweetPlayerView = {
        let view = SweetPlayerView.shard
        view.panGesture.isEnabled = false
        view.panGesture.require(toFail: pan)
        view.controlView.isHidden = true
        view.isHasVolume = false
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayController))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private var avPlayer: AVPlayer?
    
    lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "说点有意思的"
        view.delegate = self
        return view
    }()
    
    @objc private func showVideoPlayController() {
        let controller = PlayController()
        controller.avPlayer = avPlayer
        playerView.resource.scrollView = nil
        controller.resource = playerView.resource
        self.playerView.playerLayer?.playerToNil()
        self.present(controller, animated: true, completion: nil)
    }
    
    private let keyboard = KeyboardObserver()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpGray()
        view.addSubview(collectionView)
        collectionView.fill(in: view, top: UIScreen.navBarHeight())
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        addInputBottomView()
        keyboard.observe { [weak self] in self?.handleKeyboardEvent($0) }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let avPlayer = avPlayer {
            self.playerView.resource.scrollView = collectionView
            self.playerView.setAVPlayer(player: avPlayer)
        }
    }
    
    var isFetchLoadCards = false
    
    private var keyboardHeight: CGFloat = 0

    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            keyboardHeight = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
            if inputBottomView.isEditing() {
                if keyboardHeight == 0 {
                    inputBottomViewBottom?.constant = InputBottomView.defaultHeight()
                } else {
                    inputBottomViewBottom?.constant = -keyboardHeight
                }
            }
            UIView.animate(
                withDuration: event.duration,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: UInt(event.curve.rawValue)),
                animations: {
                    self.view.layoutIfNeeded()
            }, completion: nil)
        default:
            break
        }
        if event.type == .willShow {
          
        } else if event.type == .willHide {
        }
    }
    private var inputBottomViewBottom: NSLayoutConstraint?
    private var inputBottomViewHeight: NSLayoutConstraint?
    private func addInputBottomView() {
        view.addSubview(inputBottomView)
        inputBottomView.align(.left, to: view)
        inputBottomView.align(.right, to: view)
        inputBottomViewHeight = inputBottomView.constrain(height: InputBottomView.defaultHeight())
        inputBottomViewBottom = inputBottomView.align(.bottom, to: view, inset: -InputBottomView.defaultHeight())
        view.layoutIfNeeded()
    }
    
    private func contentCardLoadVideo(videoURL: URL) {
   
    }
    private func showEmptyView(isShow: Bool) {
        if isShow {
            if emptyView.superview != nil { return }
            collectionView.addSubview(emptyView)
            emptyView.frame = CGRect(x: 0,
                                     y: -10,
                                     width: collectionView.bounds.width,
                                     height: collectionView.bounds.height + 11)
            
        } else {
            emptyView.removeFromSuperview()
        }
    }
    
    private func saveLastId() {
        if self is CardsAllController {
            Defaults[.allCardsLastID] = cards[index].cardId
        } else if self is CardsSubscriptionController {
            Defaults[.subCardsLastID] = cards[index].cardId
        }
    }

}
extension CardsBaseController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
       return true
    }
}
// MARK: - Actions
extension CardsBaseController {
    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        view.endEditing(true)
        let point = gesture.location(in: nil)
        if gesture.state == .began {
            panPoint = point
            panOffset = collectionView.contentOffset
        } else if gesture.state == .changed {
//            guard index > 0 else { return }
            guard let start = panPoint, var offset = panOffset else { return }
            let translation = point.y - start.y
            offset.y -= translation
            collectionView.contentOffset = offset
        } else {
            scrollCard(withPoint: point)
        }
    }
}

// MARK: - Private
extension CardsBaseController {
    private func upLoadCards(cards: [CardResponse], callback: ((_ success: Bool) -> Void)? = nil) {
        cards.reversed().forEach({ (card) in
            self.cards.insert(card, at: 0)
            self.insertConfigurator(card: card, index: 0)
        })
        self.index += cards.count
        self.collectionView.contentOffset.y += cardCellHeight * CGFloat(cards.count)
        self.collectionView.reloadData()
        callback?(true)
//        if self.index  == 0 {
//            self.collectionView.performBatchUpdates({
//                var items = [IndexPath]()
//                for item in 0..<cards.count {
//                    items.append(IndexPath(item: item, section: 0))
//                }
//                self.collectionView.insertItems(at: items)
//            }, completion: { (_) in
//                self.index += cards.count
//                self.collectionView.contentOffset.y += cardCellHeight * CGFloat(cards.count)
//                callback?(true)
//            })
//        } else {
//            self.index += cards.count
//            self.collectionView.contentOffset.y += cardCellHeight * CGFloat(cards.count)
//            self.collectionView.reloadData()
//            callback?(true)
//        }
    }
    
    private func downLoadCards(cards: [CardResponse], callback: ((_ success: Bool) -> Void)? = nil) {
        cards.forEach({ (card) in
            self.cards.append(card)
            self.appendConfigurator(card: card)
            
        })
        let itemNumber = self.collectionView.numberOfItems(inSection: 0)
        self.collectionView.performBatchUpdates({
            var items = [IndexPath]()
            for item in 0..<cards.count {
                items.append(IndexPath(item: itemNumber + item, section: 0))
            }
            self.collectionView.insertItems(at: items)
        }, completion: { (_) in
            callback?(true)
        })
    }
}

// MARK: - Publics
extension CardsBaseController {
    
    func startLoadCards(cardRequest: CardRequst, callback: ((_ success: Bool) -> Void)? = nil) {
        if isFetchLoadCards { return }
        isFetchLoadCards = true
        let api: WebAPI
        let direction: Int?
        switch cardRequest {
        case let .all(cardId, directionApi):
            api = .allCards(cardId: cardId, direction: directionApi)
            direction = directionApi
        case let .sub(cardId, directionApi):
            api = .subscriptionCards(cardId: cardId, direction: directionApi)
            direction = directionApi
        }
        web.request(
            api,
            responseType: Response<CardListResponse>.self) { [weak self] (result) in
                guard let `self` = self else { return }
                self.isFetchLoadCards = false
                switch result {
                case let .success(response):
                    if let direction = direction {
                        if direction == Direction.down.rawValue {
                            self.downLoadCards(cards: response.list, callback: callback)
                            return
                        } else if  direction == Direction.up.rawValue {
                            self.upLoadCards(cards: response.list, callback: callback)
                            return
                        } else if direction == Direction.recover.rawValue {
                            response.list.forEach({ (card) in
                                self.cards.append(card)
                                self.appendConfigurator(card: card)
                            })
                        }
                    } else {
                        response.list.forEach({ (card) in
                            self.cards.append(card)
                            self.appendConfigurator(card: card)
                        })
                    }
                    callback?(true)
                case let .failure(error):
                    logger.error(error)
                    callback?(false)
                }
        }
    }
    
    func scrollCard(withPoint point: CGPoint) {
        guard let start = panPoint else { return }
        var direction = Direction.unknown
        if point.y < start.y {
            direction = .down
            if index == collectionView.numberOfItems(inSection: 0) - 1 {
                let cardId = cards[index].cardId
                self.startLoadCards(
                    cardRequest: self is CardsAllController ?
                    .all(cardId: cardId, direction: direction.rawValue) :
                    .sub(cardId: cardId, direction: direction.rawValue)) { (success) in
                    if success { self.index += 1 }
                    self.scrollTo(row: self.index)
                }
            } else {
                index += 1
                self.scrollTo(row: index)
            }
        } else {
            direction = .up
            if index == 0 {
                let cardId = cards[0].cardId
                self.startLoadCards(
                    cardRequest: self is CardsAllController ?
                    .all(cardId: cardId, direction: direction.rawValue) :
                    .sub(cardId: cardId, direction: direction.rawValue)) { (success) in
                    if success { self.index -= 1 }
                    self.scrollTo(row: self.index)
                }
            } else {
                if index <= 3 {
                    let cardId = cards[0].cardId
                    self.startLoadCards(
                        cardRequest: self is CardsAllController ?
                        .all(cardId: cardId, direction: direction.rawValue) :
                        .sub(cardId: cardId, direction: direction.rawValue)) { (_) in
                        self.index -=  1
                        self.scrollTo(row: self.index)
                    }
                } else {
                    self.index -=  1
                    self.scrollTo(row: index)
                }
            }
        }
    }
    
    func scrollTo(row: Int, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let offset: CGFloat =  CGFloat(row) * cardCellHeight - self.offset
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.collectionView.contentOffset.y = offset
            }, completion: { _ in
                completion?()
            })
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
    
    func insertConfigurator(card: CardResponse, index: Int) {
        switch card.type {
        case .content:
            let viewModel = ContentCardViewModel(model: card)
            let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
        case .choice:
            let viewModel = ChoiceCardViewModel(model: card)
            let configurator = CellConfigurator<ChoiceCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
        case .evaluation:
            let viewModel = EvaluationCardViewModel(model: card)
            let configurator = CellConfigurator<EvaluationCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
        case .activity:
            var viewModel = ActivitiesCardViewModel(model: card)
            for(offset, var activityViewModel) in viewModel.activityViewModels.enumerated() {
                activityViewModel.callBack = { activityItemId in
                    self.showInputView(activityItemId: activityItemId)
                }
                viewModel.activityViewModels[offset] = activityViewModel
            }
            let configurator = CellConfigurator<ActivitiesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
        case .story:
            let viewModel = StoriesCardViewModel(model: card)
            let configurator = CellConfigurator<StoriesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
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
        let newIndex = indexPath.row
        guard newIndex != index else { return }
        index = newIndex
        scrollTo(row: index)
    }
}
extension CardsBaseController: ContentCardCollectionViewCellDelegate {
    func openKeyword() {
        inputBottomView.startEditing(true)
    }
    
    func showImageBrowser(selectedIndex: Int) {
        showBrower(index: index, originPageIndex: selectedIndex)
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

extension CardsBaseController: PhotoBrowserDelegate {
    private func showBrower(index: Int, originPageIndex: Int) {
        guard cellConfigurators[index] is CellConfigurator<ContentCardCollectionViewCell>
              else { return }
        let browser = PhotoBrowser(delegate: self, originPageIndex: originPageIndex)
        browser.animationType = .scale
        browser.plugins.append(CustomNumberPageControlPlugin())
        browser.show()
    }
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        return nil
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        guard let cell = collectionView.cellForItem(
                                        at: IndexPath(item: self.index, section: 0))
                                                as? ContentCardCollectionViewCell
              else { return nil }
        return cell.imageViews[index]
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        guard let configurator = cellConfigurators[self.index] as? CellConfigurator<ContentCardCollectionViewCell>
              else { return nil }
        guard let images = configurator.viewModel.contentImages else { return nil }
        return images[index].imageURL
    }

    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        guard let configurator = cellConfigurators[index] as? CellConfigurator<ContentCardCollectionViewCell>
              else { return 0 }
        guard let images = configurator.viewModel.contentImages else { return 0 }
        return images.count
    }
}

extension CardsBaseController: InputBottomViewDelegate {
    func inputBottomViewDidChangeHeight(_ height: CGFloat) {
        inputBottomViewHeight?.constant = height + 20
    }
    
    func inputBottomViewDidPressSend(withText text: String?) {
        inputBottomView.startEditing(false)
    }
}
