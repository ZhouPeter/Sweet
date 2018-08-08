//
//  CardsBaseController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/17.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyUserDefaults
enum Direction: Int {
    case unknown = 0
    case down = 2
    case recover = 3
}
enum CardRequest {
    case all(cardId: String?, direction: Direction?)
    case sub(cardId: String?, direction: Direction?)
}
let preloadingCount = 5
var isVideoMuted = true
class CardsBaseController: BaseViewController, CardsBaseView {
    weak var delegate: CardsBaseViewDelegate?
    var user: User

    public var index = 0 {
        didSet {
            if index > maxIndex { maxIndex = index }
            if index < maxIndex - 2 {
                downButton.isHidden = false
            } else {
                downButton.isHidden = true
            }
        }
    }
    public var photoBrowserImp: PhotoBrowserImp!
    public var panPoint: CGPoint?
    public var panOffset: CGPoint?
    public var cellConfigurators = [CellConfiguratorType]()
    public var cards = [CardResponse]()
    public var activityCardId: String?
    public var activityId: String?
    public lazy var collectionView: CardsCollectionView = {
        let collectionView = CardsCollectionView()
        collectionView.dataSource = self
        collectionView.delegate = self
        pan = PanGestureRecognizer(direction: .vertical, target: self, action: #selector(didPan(_:)))
        collectionView.addGestureRecognizer(pan)
        cotentOffsetToken = collectionView.observe(
            \.contentOffset,
            options: [.new, .old],
            changeHandler: { [weak self] (object, change) in
                guard let `self` = self else { return }
                if change.newValue == change.oldValue { return }
                if floor(object.contentOffset.y + cardOffset)  == floor(CGFloat(self.index) * cardCellHeight) {
                    if self.lastIndex == self.index { return }
                    self.changeCurrentCell()
                    self.lastIndex = self.index
                }
        })
        return collectionView
    }()
    private lazy var downButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "DownArrow"), for: .normal)
        button.addTarget(self, action: #selector(didPressDownButton(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    private var maxIndex = 0
    private var lastIndex = 0
    private var delayItem: DispatchWorkItem?
    private var pan: PanGestureRecognizer!
    private var cotentOffsetToken: NSKeyValueObservation?
    private lazy var emptyView: EmptyEmojiView = {
        if self is CardsAllController {
            let view = EmptyEmojiView(image: #imageLiteral(resourceName: "AllEmptyEmoji"), title: "内容暂时没有了")
            return view
        } else {
            let view = EmptyEmojiView(image: #imageLiteral(resourceName: "EmptyEmoji"), title: "快去首页发现有趣的内容")
            return view
        }
    }()
    
    private var isFetchLoadCards = false
    
    private var avPlayer: AVPlayer?
 
    lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "说点有意思的"
        view.delegate = self
        return view
    }()
    
    @objc private func showVideoPlayController(_ tap: UITapGestureRecognizer) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VideoCardCollectionViewCell {
            cell.playerView.hero.isEnabled = true
            cell.playerView.hero.id = cards[index].video
            cell.playerView.hero.modifiers = [.arc]
            let controller = PlayController()
            controller.hero.isEnabled = true
            controller.avPlayer = avPlayer
            controller.resource = cell.playerView.resource
            cell.playerView.playerLayer?.playerToNil()
            self.present(controller, animated: true, completion: nil)
            isVideoMuted = false
            cell.playerView.isVideoMuted = isVideoMuted
            CardAction.clickVideo.actionLog(card: cards[index])
        }
     
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
        collectionView.fill(in: view)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(downButton)
        downButton.constrain(width: 60, height: 60)
        downButton.align(.right, inset: 10)
        downButton.align(.bottom, inset: 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let avPlayer = avPlayer {
            if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VideoCardCollectionViewCell {
                cell.playerView.setAVPlayer(player: avPlayer)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VideoCardCollectionViewCell {
            cell.playerView.pause()
        }
    }
    deinit {
        cotentOffsetToken?.invalidate()
        logger.debug("首页释放")
    }
    
    private func showEmptyView(isShow: Bool) {
        if isShow {
            if emptyView.superview != nil { return }
            collectionView.addSubview(emptyView)
            if self is CardsAllController {
                if isFetchLoadCards {
                    emptyView.update(image: #imageLiteral(resourceName: "CardLoading"), title: "加载中")
                } else  {
                    emptyView.update(image: #imageLiteral(resourceName: "AllEmptyEmoji"), title: "内容暂时没有了")
                }
            }
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
            let velocityY = gesture.velocity(in: nil).y
            scrollCard(withPoint: point, velocityY: velocityY)
        }
    }
    @objc private func didPressDownButton(_ sender: UIButton) {
        index = maxIndex
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
    
    func scrollTo(row: Int, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
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
        for cell in collectionView.visibleCells {
            if let cell = cell as? VideoCardCollectionViewCell {
                cell.playerView.pause()
            }
        }
        if self.cellConfigurators.count == 0 { return }
        let indexPath = IndexPath(item: self.index, section: 0)
        let configurator = self.cellConfigurators[self.index]
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if let cell = cell as? VideoCardCollectionViewCell,
            let configurator = configurator as? CellConfigurator<VideoCardCollectionViewCell> {
            cell.playerView.delegate = self
            cell.playerView.panGesture.isEnabled = false
            cell.playerView.panGesture.require(toFail: pan)
            if let gestures = cell.playerView.controlView.gestureRecognizers {
                for gesture in gestures {
                    cell.playerView.controlView.removeGestureRecognizer(gesture)
                }
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayController(_:)))
            cell.playerView.controlView.addGestureRecognizer(tap)
            if let resource = cell.playerView.resource,
                resource.indexPath == indexPath,
                resource.definitions[0].url == configurator.viewModel.videoURL {
                if let asset = cell.playerView.avPlayer?.currentItem?.asset, asset.isPlayable {
                } else {
                    cell.playerView.setVideo(resource: resource)
                }
                cell.playerView.isVideoMuted = isVideoMuted
                cell.playerView.seek(configurator.viewModel.currentTime) {
                    cell.playerView.play()
                }
                avPlayer = cell.playerView.avPlayer
                return
            }
            let resource = SweetPlayerResource(url: configurator.viewModel.videoURL)
            resource.indexPath = indexPath
            cell.playerView.setVideo(resource: resource)
            cell.playerView.isVideoMuted = isVideoMuted
            cell.playerView.seek(configurator.viewModel.currentTime) {
                cell.playerView.play()
            }
            avPlayer = cell.playerView.avPlayer
        }
    }

    private func scrollCard(withPoint point: CGPoint, velocityY: CGFloat) {
        guard let start = panPoint else {
            pan.isEnabled = true
            return
        }
        var direction = Direction.unknown
        let targetY = point.y + velocityY
        let offset = start.y - targetY
        let threshold = cardCellHeight * 0.3
        if offset < -threshold {
            if index == 0 {
                self.scrollTo(row: index)
            } else {
                self.index -=  1
                self.scrollTo(row: index)
            }
        } else if offset > threshold {
            direction = .down
            let maxIndex = collectionView.numberOfItems(inSection: 0) - 1
            if index == maxIndex {
                let cardId = cards[index].cardId
                let request: CardRequest = self is CardsAllController ?
                    .all(cardId: cardId, direction: direction) :
                    .sub(cardId: cardId, direction: direction)
                self.startLoadCards(cardRequest: request) { (success, cards) in
                    if let cards = cards, cards.count > 0, success { self.index += 1 }
                    self.scrollTo(row: self.index)
                }
            } else if index < maxIndex {
                self.preloadingCard()
                index += 1
                self.scrollTo(row: index)
            } else if index > maxIndex {
                index = max(maxIndex, 0)
                self.scrollTo(row: index)
            }
        } else {
            self.scrollTo(row: index)
        }
    }
    
    private func preloadingCard() {
        if self.collectionView.numberOfItems(inSection: 0) - 1 - index < preloadingCount {
            let cardId = cards[index].cardId
            let direction = Direction.down
            let request: CardRequest = self is CardsAllController ?
                .all(cardId: cardId, direction: direction) :
                .sub(cardId: cardId, direction: direction)
            self.startLoadCards(cardRequest: request)
        }
    }
    
    private func showWebView(indexPath: IndexPath) {
        let card = cards[indexPath.row]
        guard let url = card.url else { return }
        let preview = ShareWebViewController(urlString: url, card: card)
        if card.cardEnumType == .content  {
            if let configurator = cellConfigurators[indexPath.row] as? CellConfigurator<ContentCardCollectionViewCell> {
                preview.emojiDisplay = configurator.viewModel.emojiDisplayType
            }
            if let configurator = cellConfigurators[indexPath.row] as? CellConfigurator<VideoCardCollectionViewCell> {
                preview.emojiDisplay = configurator.viewModel.emojiDisplayType
            }
        }
        preview.navigationBarColors = [UIColor(hex:0x66E5FF), UIColor(hex: 0x36C6FD)]
        preview.delegate = self
        navigationController?.pushViewController(preview, animated: true)
        CardAction.clickUrl.actionLog(card: card)
        CardTimerHelper.countDown(time: 10, countDownBlock: { time in
            guard let last = self.navigationController?.viewControllers.last,
                  let webController = last as? WebViewController,
                  webController.urlString == card.url else {
                CardTimerHelper.cancelTimer()
                return
            }
        }) {
            if let last = self.navigationController?.viewControllers.last,
                let webController = last as? WebViewController,
                webController.urlString == card.url {
                CardAction.clickUrlBack.actionLog(card: card)
            }
        }
    }
}
// MARK: - UICollectionViewDataSource
extension CardsBaseController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        showEmptyView(isShow: cellConfigurators.count == 0)
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
// MARK: - UICollectionViewDelegate
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
