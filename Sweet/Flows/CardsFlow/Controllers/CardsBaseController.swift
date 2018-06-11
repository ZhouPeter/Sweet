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
    case down = 2
    case recover = 3
}
enum CardRequst {
    case all(cardId: String?, direction: Direction?)
    case sub(cardId: String?, direction: Direction?)
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
    private var activityCardId: String?
    private var activityId: String?
    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.bounds.width, height: cardCellHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        collectionView.contentInset.top = offset
        collectionView.contentInset.bottom = UIScreen.mainHeight() - cardCellHeight - offset - UIScreen.navBarHeight()
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: ContentCardCollectionViewCell.self)
        collectionView.register(cellType: VideoCardCollectionViewCell.self)
        collectionView.register(cellType: ChoiceCardCollectionViewCell.self)
        collectionView.register(cellType: EvaluationCardCollectionViewCell.self)
        collectionView.register(cellType: ActivitiesCardCollectionViewCell.self)
        collectionView.register(cellType: StoriesCardCollectionViewCell.self)
        pan = PanGestureRecognizer(direction: .vertical, target: self, action: #selector(didPan(_:)))
        pan.delegate = self
        collectionView.addGestureRecognizer(pan)
        cotentOffsetToken = collectionView.observe(
            \.contentOffset,
            options: [.new, .old],
            changeHandler: { (object, change) in
            if change.newValue == change.oldValue { return }
            if object.contentOffset.y + self.offset  == CGFloat(self.index) * cardCellHeight {
                self.changeCurrentCell()
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
        Messenger.shared.addDelegate(self)

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
            if index < cards.count {
                Defaults[.allCardsLastID] = cards[index].cardId
            }
        } else if self is CardsSubscriptionController {
            if index < cards.count {
                Defaults[.subCardsLastID] = cards[index].cardId
            }
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
            guard let start = panPoint, var offset = panOffset else { return }
            let translation = point.y - start.y
            offset.y -= translation
            collectionView.contentOffset = offset
        } else {
            gesture.isEnabled = false
            scrollCard(withPoint: point)
        }
    }
}

// MARK: - Private
extension CardsBaseController {
    private func upLoadCards(cards: [CardResponse],
                             callback: ((_ success: Bool, _ cards: [CardResponse]?) -> Void)? = nil) {
        cards.reversed().forEach({ (card) in
            self.insertConfigurator(card: card, index: 0)
        })
        self.index += cards.count
        self.collectionView.contentOffset.y += cardCellHeight * CGFloat(cards.count)
        self.collectionView.reloadData()
        callback?(true, cards)
    }
    
    private func downLoadCards(cards: [CardResponse],
                               callback: ((_ success: Bool, _ cards: [CardResponse]?) -> Void)? = nil) {
        cards.forEach({ (card) in
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
            callback?(true, cards)
        })
    }
}

// MARK: - Publics
extension CardsBaseController {
    func changeCurrentCell() {
        self.saveLastId()
        self.delayItem?.cancel()
        if self.cellConfigurators.count == 0 { return }
        let indexPath = IndexPath(item: self.index, section: 0)
        let configurator = self.cellConfigurators[self.index]
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if let cell = cell as? VideoCardCollectionViewCell,
            let configurator = configurator as? CellConfigurator<VideoCardCollectionViewCell> {
            weak var weakSelf = self
            weak var weakCell = cell
            let resource = SweetPlayerResource(url: configurator.viewModel.videoURL)
            resource.indexPath = indexPath
            resource.scrollView = weakSelf?.collectionView
            resource.fatherViewTag = weakCell?.contentImageView.tag
            self.playerView.setVideo(resource: resource)
            self.avPlayer = self.playerView.avPlayer
            self.delayItem = DispatchWorkItem {
                cell.hiddenEmojiView(isHidden: false)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: self.delayItem!)
        }
    }
    
    func startLoadCards(cardRequest: CardRequst,
                        callback: ((_ success: Bool, _ cards: [CardResponse]?) -> Void)? = nil) {
        if isFetchLoadCards {
            scrollTo(row: index)
            return
        }
        isFetchLoadCards = true
        let api: WebAPI
        let direction: Direction?
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
                switch result {
                case let .success(response):
                    self.isFetchLoadCards = false
                    if let direction = direction {
                        if direction == Direction.down {
                            self.downLoadCards(cards: response.list, callback: callback)
                            return
                        } else if direction == Direction.recover {
                            response.list.forEach({ (card) in
                                self.appendConfigurator(card: card)
                            })
                        }
                    } else {
                        response.list.forEach({ (card) in
                            self.appendConfigurator(card: card)
                        })
                    }
                    callback?(true, response.list)
                case let .failure(error):
                    logger.error(error)
                    self.isFetchLoadCards = false
                    callback?(false, nil)
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
                let request: CardRequst = self is CardsAllController ?
                                                .all(cardId: cardId, direction: direction) :
                                                .sub(cardId: cardId, direction: direction)
                self.startLoadCards(cardRequest: request) { (success, cards) in
                    if let cards = cards, cards.count > 0, success { self.index += 1 }
                    self.scrollTo(row: self.index)
                }
            } else if index < collectionView.numberOfItems(inSection: 0) - 1 {
                index += 1
                self.scrollTo(row: index)
            }
        } else {
            if index == 0 {
                self.scrollTo(row: self.index)
            } else {
                self.index -=  1
                self.scrollTo(row: index)
            }

        }
    }
    
    func scrollTo(row: Int, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.pan.isEnabled = true
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
            if card.video != nil {
                let viewModel = ContentVideoCardViewModel(model: card)
                let configurator = CellConfigurator<VideoCardCollectionViewCell>(viewModel: viewModel)
                cellConfigurators.append(configurator)
                cards.append(card)
            } else {
                let viewModel = ContentCardViewModel(model: card)
                let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
                cellConfigurators.append(configurator)
                cards.append(card)
            }
        case .choice:
            let viewModel = ChoiceCardViewModel(model: card)
            let configurator = CellConfigurator<ChoiceCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        case .evaluation:
            let viewModel = EvaluationCardViewModel(model: card)
            let configurator = CellConfigurator<EvaluationCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        case .activity:
            var viewModel = ActivitiesCardViewModel(model: card)
            for(offset, var activityViewModel) in viewModel.activityViewModels.enumerated() {
                activityViewModel.callBack = { activityId in
                    self.showInputView(cardId: viewModel.cardId, activityId: activityId)
                }
                viewModel.activityViewModels[offset] = activityViewModel
            }
            let configurator = CellConfigurator<ActivitiesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        case .story:
            let viewModel = StoriesCardViewModel(model: card)
            let configurator = CellConfigurator<StoriesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        default: break
        }
    }
    
    func insertConfigurator(card: CardResponse, index: Int) {
        switch card.type {
        case .content:
            if card.video != nil {
                let viewModel = ContentVideoCardViewModel(model: card)
                let configurator = CellConfigurator<VideoCardCollectionViewCell>(viewModel: viewModel)
                cellConfigurators.insert(configurator, at: index)
                cards.insert(card, at: index)
            } else {
                let viewModel = ContentCardViewModel(model: card)
                let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
                cellConfigurators.insert(configurator, at: index)
                cards.insert(card, at: index)
            }
        case .choice:
            let viewModel = ChoiceCardViewModel(model: card)
            let configurator = CellConfigurator<ChoiceCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
            cards.insert(card, at: index)
        case .evaluation:
            let viewModel = EvaluationCardViewModel(model: card)
            let configurator = CellConfigurator<EvaluationCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
            cards.insert(card, at: index)
        case .activity:
            var viewModel = ActivitiesCardViewModel(model: card)
            for(offset, var activityViewModel) in viewModel.activityViewModels.enumerated() {
                activityViewModel.callBack = { activityId in
                    self.showInputView(cardId: viewModel.cardId, activityId: activityId)
                }
                viewModel.activityViewModels[offset] = activityViewModel
            }
            let configurator = CellConfigurator<ActivitiesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
            cards.insert(card, at: index)
        case .story:
            let viewModel = StoriesCardViewModel(model: card)
            let configurator = CellConfigurator<StoriesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.insert(configurator, at: index)
            cards.insert(card, at: index)
        default: break
        }
    }

    private func showInputView(cardId: String, activityId: String) {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(inputTextView)
        inputTextView.fill(in: window)
        inputTextView.startEditing(isStarted: true)
        self.activityId = activityId
        self.activityCardId = cardId
        
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
        if cell is VideoCardCollectionViewCell {
            if let playerIndex = playerView.resource?.indexPath, playerIndex == indexPath {
                playerView.updatePlayViewToCell(cell: cell)
            }
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

extension CardsBaseController: ChoiceCardCollectionViewCellDelegate {
    func selectChoiceCard(cardId: String, selectedIndex: Int) {
        web.request(
            .choiceCard(cardId: cardId, index: selectedIndex),
            responseType: Response<SelectResult>.self) { (result) in
            switch result {
            case let .success(response):
                guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
                self.cards[index].result = response
                let viewModel = ChoiceCardViewModel(model: self.cards[index])
                let configurator = CellConfigurator<ChoiceCardCollectionViewCell>(viewModel: viewModel)
                self.cellConfigurators[index] = configurator
                self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}
extension CardsBaseController: StoriesCardCollectionViewCellDelegate {
    func showStoriesPlayerController(storiesGroup: [[StoryCellViewModel]], currentIndex: Int, cardId: String?) {
        let controller = StoriesPlayerGroupViewController(storiesGroup: storiesGroup,
                                                          currentIndex: currentIndex,
                                                          fromCardId: cardId)
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        self.readGroup(storyGroupIndex: currentIndex)
    }
}

extension CardsBaseController: EvaluationCardCollectionViewCellDelegate {
    func selectEvaluationCard(cell: EvaluationCardCollectionViewCell, cardId: String, selectedIndex: Int) {
        web.request(.evaluateCard(cardId: cardId, index: selectedIndex)) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
                guard let index = self.cards.index(where: { $0.cardId == cardId }),
                      self.cards[index].type == .evaluation else { return }
                self.cards[index].result = SelectResult(contactUserList: [SelectResult.UserAvatar](),
                                                        index: selectedIndex,
                                                        percent: 0,
                                                        comment: nil,
                                                        emoji: nil)
                let viewModel = EvaluationCardViewModel(model: self.cards[index])
                let configurator = CellConfigurator<EvaluationCardCollectionViewCell>(viewModel: viewModel)
                self.cellConfigurators[index] = configurator
                cell.updateWith(selectedIndex)
                if !Defaults[.isEvaluationOthers] {
                    let alert = UIAlertController(title: "你的好友将会收到你的评价",
                                                  message: "下次不再提示",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                Defaults[.isEvaluationOthers] = true
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension CardsBaseController: ContentCardCollectionViewCellDelegate {
    func contentCardComment(cardId: String, emoji: Int) {
        web.request(
            .commentCard(cardId: cardId, comment: "", emoji: emoji),
            responseType: Response<SelectResult>.self) { (result) in
                switch result {
                case let .success(response):
                    guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
                    self.cards[index].result = response
                    let viewModel = ContentVideoCardViewModel(model: self.cards[index])
                    let configurator = CellConfigurator<VideoCardCollectionViewCell>(viewModel: viewModel)
                    self.cellConfigurators[index] = configurator
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    
    func openKeyword() {
        inputBottomView.startEditing(true)
    }
    
    func showImageBrowser(selectedIndex: Int) {
        showBrower(index: index, originPageIndex: selectedIndex)
    }
}

extension CardsBaseController: BaseCardCollectionViewCellDelegate {
    func showAlertController(cardId: String, fromCell: BaseCardCollectionViewCell) {
        guard  let index = cards.index(where: { $0.cardId == cardId }) else { fatalError() }
        let cardType = cards[index].type
        if cardType == .activity {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let reportAction = UIAlertAction.makeAlertAction(title: "投诉", style: .destructive) { (_) in
                web.request(.cardReport(cardId: cardId), completion: { (_) in
                })
            }
            let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(reportAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let sectionId = cards[index].sectionId!
        web.request(.sectionStatus(sectionId: sectionId),
                    responseType: Response<StatusResponse>.self) { (result) in
            switch result {
            case let .success(response):
                let alert = self.makeAlertController(status: response,
                                                     cardType: cardType,
                                                     cardId: cardId,
                                                     sectionId: sectionId)
                self.present(alert, animated: true, completion: nil)
            case let .failure(error):
                logger.error(error)
            }
        }
       
    }
    
    private func makeAlertController(status: StatusResponse,
                                     cardType: CardResponse.CardType,
                                     cardId: String,
                                     sectionId: UInt64) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareAction = UIAlertAction.makeAlertAction(title: "分享给联系人", style: .default) { (_) in
            let controller = ShareCardController()
            controller.sendCallback = { (text, userIds) in
                self.sendMessge(cardId: cardId, text: text, userIds: userIds)
            }
            self.present(controller, animated: true, completion: nil)
        }
        let subscriptionAction = UIAlertAction.makeAlertAction(
                title: status.subscription ? "取消订阅" : "订阅该栏目",
                style: .default) { (_) in
            if status.subscription {
                web.request(.delSectionSubscription(sectionId: sectionId), completion: { (_) in
                })
            } else {
                web.request(.addSectionSubscription(sectionId: sectionId), completion: { (_) in
                })
            }
        }
        let blockAction = UIAlertAction.makeAlertAction(
                title: status.block ? "取消屏蔽" : "屏蔽该栏目",
                style: .default) { (_) in
            if status.block {
                web.request(.delSectionBlock(sectionId: sectionId), completion: { (_) in
                })
            } else {
                web.request(.addSectionBlock(sectionId: sectionId), completion: { (_) in
                })
            }
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(shareAction)
        alertController.addAction(subscriptionAction)
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    private func sendMessge(cardId: String, text: String, userIds: [UInt64]) {
        guard let index = cards.index(where: { $0.cardId == cardId }) else {fatalError()}
        let card  = cards[index]
        let from = UInt64(Defaults[.userID]!)!
        if card.type == .content {
            let url: String
            if let videoUrl = card.video {
                url = videoUrl + "?vsample/jpg/offset/0.0/w/375/h/667"
            } else {
                url = card.contentImageList![0].url
            }
            let content = ContentCardContent(identifier: cardId,
                                             cardType: InstantMessage.CardType.content,
                                             text: card.content!,
                                             imageURLString: url,
                                             url: card.url!)
            userIds.forEach {
                Messenger.shared.sendContentCard(content, from: from, to: $0, extra: cardId)
                if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: cardId) }
                web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
            }
        } else if card.type == .choice {
            let result = card.result == nil ? -1 : card.result!.index!
            let content = OptionCardContent(identifier: cardId,
                                            cardType: InstantMessage.CardType.preference,
                                            text: card.content!,
                                            leftImageURLString: card.imageList![0],
                                            rightImageURLString: card.imageList![1],
                                            result: OptionCardContent.Result(rawValue: result)!)
            userIds.forEach {
                Messenger.shared.sendPreferenceCard(content, from: from, to: $0, extra: cardId)
                if text != "" { Messenger.shared.sendText(text, from: from, to: $0) }
                web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
            }
        } else if card.type == .evaluation {
            let result = card.result == nil ? -1 : card.result!.index!
            let content = OptionCardContent(identifier: cardId,
                                            cardType: InstantMessage.CardType.evaluation,
                                            text: card.content!,
                                            leftImageURLString: card.imageList![0],
                                            rightImageURLString: card.imageList![1],
                                            result: OptionCardContent.Result(rawValue: result)!)
            userIds.forEach {
                Messenger.shared.sendEvaluationCard(content, from: from, to: $0, extra: cardId)
                if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: cardId) }
                web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
            }
        }
        NotificationCenter.default.post(name: .dismissShareCard, object: nil)
    }
}

extension CardsBaseController: StoriesPlayerGroupViewControllerDelegate {
    func readGroup(storyGroupIndex: Int) {
        if self.cards[index].type == .story {
            let storyId = self.cards[index].storyList![storyGroupIndex][0].storyId
            let fromCardId = self.cards[index].cardId
            web.request(.storyRead(storyId: storyId, fromCardId: fromCardId)) { (result) in
                switch result {
                case .success:
                    guard let index = self.cards.index(where: { $0.cardId == fromCardId }) else { return }
                    let storys = self.cards[index].storyList![storyGroupIndex]
                    var newStorys = [StoryResponse]()
                    for var story in storys {
                        story.read = true
                        newStorys.append(story)
                    }
                    self.cards[index].storyList![storyGroupIndex] = newStorys
                    var viewModel = StoriesCardViewModel(model: self.cards[index])
                    viewModel.storyCellModels[storyGroupIndex].isRead = true
                    let configurator = CellConfigurator<StoriesCardCollectionViewCell>(viewModel: viewModel)
                    self.cellConfigurators[index] = configurator
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                case let .failure(error):
                    logger.error(error)
                }
            }
        }
    }

}

// MARK: - PhotoBrowserDelegate
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
// MARK: - InputBottomViewDelegate
extension CardsBaseController: InputBottomViewDelegate {
    func inputBottomViewDidChangeHeight(_ height: CGFloat) {
        inputBottomViewHeight?.constant = height + 20
    }
    
    func inputBottomViewDidPressSend(withText text: String?) {
        guard cards[index].type == .content else { return }
        let cardId = self.cards[index].cardId
        web.request(
            .commentCard(cardId: cardId, comment: text!, emoji: 0),
            responseType: Response<SelectResult>.self) {(result) in
                switch result {
                case let .success(response):
                    guard cardId == self.cards[self.index].cardId else { return }
                    self.cards[self.index].result = response
                    let viewModel = ContentCardViewModel(model: self.cards[self.index])
                    let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
                    self.cellConfigurators[self.index] = configurator
                    self.collectionView.reloadItems(at: [IndexPath(item: self.index, section: 0)])
                case let .failure(error):
                    logger.error(error)
                }
        }
        inputBottomView.startEditing(false)
    }
}

// MARK: - InputTextViewDelegate
extension CardsBaseController: InputTextViewDelegate {
    func inputTextViewDidPressSendMessage(text: String) {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
        sendActivityMessages(text: text)
   
    }
    
    func removeInputTextView() {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
    }
}

extension CardsBaseController: MessengerDelegate {
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {
        if success {
        } else {
            self.toast(message: "发送失败")
        }
    }
}

// MARK: - ActivityMessage Methods
extension CardsBaseController {
    func sendActivityMessages(text: String) {
        let card = cards[index]
        let from = UInt64(Defaults[.userID]!)!
        guard let cardId = activityCardId, let activityId = activityId else { return }
        guard card.type == .activity, card.cardId == cardId else { return }
        guard let index = card.activityList!.index(where: { $0.activityId == activityId }) else {fatalError()}
        let toUserId = card.activityList![index].actor
        let cardID = card.activityList![index].fromCardId
        web.request(
            WebAPI.getCard(cardID: cardID),
            responseType: Response<CardGetResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    let resultCard = response.card
                    if let content = MessageContentHelper.getContentCardContent(resultCard: resultCard) {
                        if resultCard.type == .content, let content = content as? ContentCardContent {
                            Messenger.shared.sendContentCard(content, from: from, to: toUserId, extra: activityId)
                        } else if resultCard.type == .choice, let content = content as? OptionCardContent {
                            Messenger.shared.sendPreferenceCard(content, from: from, to: toUserId, extra: activityId)
                        }
                    } else {
                        return
                    }
                    Messenger.shared.sendLike(from: from, to: toUserId, extra: activityId)
                    if text != "" { Messenger.shared.sendText(text, from: from, to: toUserId, extra: activityId) }
                    self.requestActivityCardLike(cardId: cardId, activityId: activityId, comment: text)
                case let .failure(error):
                    logger.error(error)
                }
        }
    }

    private func requestActivityCardLike(cardId: String, activityId: String, comment: String) {
        web.request(.activityCardLike(cardId: cardId, activityId: activityId, comment: comment)) { (result) in
            switch result {
            case .success:
                guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
                guard let item = self.cards[index].activityList!.index(
                    where: { $0.activityId == activityId }) else { return }
                self.cards[index].activityList![item].like = true
                let viewModel = ActivitiesCardViewModel(model: self.cards[index])
                let configurator = CellConfigurator<ActivitiesCardCollectionViewCell>(viewModel: viewModel)
                self.cellConfigurators[index] = configurator
                if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)),
                    let acCell = cell as? ActivitiesCardCollectionViewCell {
                    acCell.updateItem(item: item, like: true)
                }
                self.toast(message: "❤️ 评价成功")
            case let  .failure(error):
                logger.error(error)
            }
        }
    }
}
