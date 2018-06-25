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
import Kingfisher
import TapticEngine
enum Direction: Int {
    case unknown = 0
    case down = 2
    case recover = 3
}
enum CardRequest {
    case all(cardId: String?, direction: Direction?)
    case sub(cardId: String?, direction: Direction?)
}

class CardsBaseController: BaseViewController, CardsBaseView {
    weak var delegate: CardsBaseViewDelegate?
    var user: User
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
    
    private lazy var downButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "DownArrow"), for: .normal)
        button.addTarget(self, action: #selector(didPressDownButton(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    public var index = 0 {
        didSet {
            
            if index < cellConfigurators.count - 3 {
                downButton.isHidden = false
            } else {
                downButton.isHidden = true
            }
        }
    }
    public var panPoint: CGPoint?
    public var panOffset: CGPoint?
    public var cellConfigurators = [CellConfiguratorType]()
    public var cards = [CardResponse]()
    public var activityCardId: String?
    public var activityId: String?
    private var pan: PanGestureRecognizer!
    private var cotentOffsetToken: NSKeyValueObservation?
    public lazy var collectionView: CardsCollectionView = {
        let collectionView = CardsCollectionView()
        collectionView.dataSource = self
        collectionView.delegate = self
        pan = PanGestureRecognizer(direction: .vertical, target: self, action: #selector(didPan(_:)))
        collectionView.addGestureRecognizer(pan)
        cotentOffsetToken = collectionView.observe(
            \.contentOffset,
            options: [.new, .old],
            changeHandler: { (object, change) in
            if change.newValue == change.oldValue { return }
            if object.contentOffset.y + cardOffset  == CGFloat(self.index) * cardCellHeight {
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
        let view = SweetPlayerView(controlView: SweetPlayerCellControlView())
        view.panGesture.isEnabled = false
        view.panGesture.require(toFail: pan)
        view.isHasVolume = false
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayController))
        view.controlView.addGestureRecognizer(tap)
        return view
    }()
    
    private var isFetchLoadCards = false
    private var avPlayer: AVPlayer?
    private let keyboard = KeyboardObserver()
    private var keyboardHeight: CGFloat = 0
    private var inputBottomViewBottom: NSLayoutConstraint?
    private var inputBottomViewHeight: NSLayoutConstraint?
    private var photoBrowserImp: PhotoBrowserImp!
    lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "说点有意思的"
        view.delegate = self
        return view
    }()
    
    @objc private func showVideoPlayController() {
        playerView.hero.isEnabled = true
        playerView.hero.id = cards[index].video
        playerView.hero.modifiers = [.arc]
        let controller = PlayController()
        controller.hero.isEnabled = true
        controller.avPlayer = avPlayer
        playerView.resource.scrollView = nil
        controller.resource = playerView.resource
        self.playerView.playerLayer?.playerToNil()
        self.present(controller, animated: true, completion: nil)
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        view.addSubview(downButton)
        downButton.constrain(width: 60, height: 60)
        downButton.align(.right, inset: 10)
        downButton.align(.bottom, inset: 10)
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

    private func addInputBottomView() {
        view.addSubview(inputBottomView)
        inputBottomView.align(.left, to: view)
        inputBottomView.align(.right, to: view)
        inputBottomViewHeight = inputBottomView.constrain(height: InputBottomView.defaultHeight())
        inputBottomViewBottom = inputBottomView.align(.bottom, to: view, inset: -InputBottomView.defaultHeight())
        view.layoutIfNeeded()
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
    @objc private func didPressDownButton(_ sender: UIButton) {
        index = cellConfigurators.count - 1
        scrollTo(row: index)
    }
}

// MARK: - Private
extension CardsBaseController {
    func startLoadCards(cardRequest: CardRequest,
                        callback: ((_ success: Bool, _ cards: [CardResponse]?) -> Void)? = nil) {
        if isFetchLoadCards {
            scrollTo(row: index)
            return
        }
        isFetchLoadCards = true
        let api: WebAPI
        let direction: Direction?
        switch cardRequest {
        case let .all(cardId, requestDirection):
            api = .allCards(cardId: cardId, direction: requestDirection)
            direction = requestDirection
        case let .sub(cardId, requestDirection):
            api = .subscriptionCards(cardId: cardId, direction: requestDirection)
            direction = requestDirection
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
                            response.list.forEach({ self.appendConfigurator(card: $0) })
                        }
                    } else {
                        response.list.forEach({ self.appendConfigurator(card: $0) })
                    }
                    callback?(true, response.list)
                case let .failure(error):
                    if error.code == WebErrorCode.noCard.rawValue && direction == Direction.down {
                        self.toast(message: "全部看完啦")
                    }
                    logger.error(error)
                    self.isFetchLoadCards = false
                    callback?(false, nil)
                }
        }
    }
}

// MARK: - Privates
extension CardsBaseController {
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
    
    func changeCurrentCell() {
        self.saveLastId()
        self.delayItem?.cancel()
        self.playerView.isHasVolume = false
        self.playerView.pause()
//        self.playerView.playerLayer?.resetPlayer()
        if self.cellConfigurators.count == 0 { return }
        let indexPath = IndexPath(item: self.index, section: 0)
        let configurator = self.cellConfigurators[self.index]
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if let cell = cell as? ContentCardCollectionViewCell {
            self.delayItem = DispatchWorkItem {
                cell.hiddenEmojiView(isHidden: false)
                self.showCellEmojiView(emojiDisplayType: .show, index: self.index)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: self.delayItem!)
        } else if let cell = cell as? VideoCardCollectionViewCell,
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
                self.showCellEmojiView(emojiDisplayType: .show, index: self.index)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: self.delayItem!)
        }
    }

    private func showCellEmojiView(emojiDisplayType: EmojiViewDisplay, index: Int) {
        if cards[index].type == .content {
            if var configurator = cellConfigurators[index] as? CellConfigurator<ContentCardCollectionViewCell> {
                configurator.viewModel.emojiDisplayType = emojiDisplayType
                cellConfigurators[index] = configurator
            }
            if var configurator = cellConfigurators[index] as? CellConfigurator<VideoCardCollectionViewCell> {
                configurator.viewModel.emojiDisplayType = emojiDisplayType
                cellConfigurators[index] = configurator
            }
        }
    }
    private func scrollCard(withPoint point: CGPoint) {
        guard let start = panPoint else { return }
        var direction = Direction.unknown
        if point.y < start.y {
            direction = .down
            if index == collectionView.numberOfItems(inSection: 0) - 1 {
                let cardId = cards[index].cardId
                let request: CardRequest = self is CardsAllController ?
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
                self.scrollTo(row: index)
            } else {
                self.index -=  1
                self.scrollTo(row: index)
            }
        }
    }
    
    private func scrollTo(row: Int, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if row == self.cards.count - 1 {
                let cardId = self.cards[row].cardId
                let direction = Direction.down
                let request: CardRequest = self is CardsAllController ?
                    .all(cardId: cardId, direction: direction) :
                    .sub(cardId: cardId, direction: direction)
                self.startLoadCards(cardRequest: request)
            }
            self.pan.isEnabled = true
            let offset: CGFloat =  CGFloat(row) * cardCellHeight - cardOffset
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
    
    func showWebView(indexPath: IndexPath) {
        let card = cards[indexPath.row]
        guard let url = card.url else { return }
        let preview = WebViewController(urlString: url)
        preview.title = card.content
        navigationController?.pushViewController(preview, animated: true)
    }
}

extension CardsBaseController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self is CardsSubscriptionController {
            showEmptyView(isShow: cellConfigurators.count == 0)
        }
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
        if newIndex == index {
            showWebView(indexPath: indexPath)
        } else {
            index = newIndex
            scrollTo(row: index)
        }
    }
}

extension CardsBaseController: ChoiceCardCollectionViewCellDelegate {
    func showProfile(userId: UInt64) {
        delegate?.showProfile(userId: userId)
    }
    
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
                self.vibrateFeedback()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension CardsBaseController: StoriesCardCollectionViewCellDelegate {
    func showStoriesPlayerController(cell: UICollectionViewCell,
                                     storiesGroup: [[StoryCellViewModel]],
                                     currentIndex: Int,
                                     cardId: String?) {
        if let index = cards.index(where: { $0.cardId == cardId}) {
            if index != self.index {
                self.index = index
                scrollTo(row: self.index)
                return
            }
        }
        delegate?.showStoriesGroup(
            user: user,
            storiesGroup: storiesGroup,
            currentIndex: currentIndex,
            fromCardId: cardId,
            delegate: self,
            completion: {}
        )
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
                self.vibrateFeedback()
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
                    self.reloadContentCell(index: index)
                    self.vibrateFeedback()
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    
    func openKeyboard() {
        inputBottomView.startEditing(true)
    }
    
    func openEmojis(cardId: String) {
        guard let index = cards.index(where: { $0.cardId == cardId }) else { return }
        showCellEmojiView(emojiDisplayType: .allShow, index: index)
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
                web.request(.cardReport(cardId: cardId), completion: { (_) in })
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
    
}

extension CardsBaseController: StoriesPlayerGroupViewControllerDelegate {
    func readGroup(storyId: UInt64, fromCardId: String?, storyGroupIndex: Int) {
        if self.cards[index].type == .story {
            web.request(.storyRead(storyId: storyId, fromCardId: fromCardId)) { (result) in
                switch result {
                case .success:
                    if storyGroupIndex > 3 { return }
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

extension CardsBaseController {
    private func showBrower(index: Int, originPageIndex: Int) {
        guard let configurator = cellConfigurators[index] as? CellConfigurator<ContentCardCollectionViewCell>
              else { return }
        guard let cell = collectionView.cellForItem(at: IndexPath(item: self.index, section: 0))
                                            as? ContentCardCollectionViewCell else { return  }
        let imagURLs = configurator.viewModel.contentImages!.flatMap({ $0.compactMap { URL(string: $0.url) } })
        self.photoBrowserImp = PhotoBrowserImp(thumbnaiImageViews: cell.imageViews, highImageViewURLs: imagURLs)
        let browser = PhotoBrowser(delegate: photoBrowserImp, originPageIndex: originPageIndex)
        browser.animationType = .scale
        browser.plugins.append(CustomNumberPageControlPlugin())
        browser.show()
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
                    self.reloadContentCell(index: self.index)
                    self.vibrateFeedback()
                case let .failure(error):
                    logger.error(error)
                }
        }
        inputBottomView.startEditing(false)
    }
}
