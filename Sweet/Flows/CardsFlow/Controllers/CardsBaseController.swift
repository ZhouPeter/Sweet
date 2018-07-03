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
import Kingfisher
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
            changeHandler: { (object, change) in
            if change.newValue == change.oldValue { return }
            if object.contentOffset.y + cardOffset  == CGFloat(self.index) * cardCellHeight {
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
        Messenger.shared.addDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let avPlayer = avPlayer {
            self.playerView.resource.scrollView = collectionView
            self.playerView.setAVPlayer(player: avPlayer)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playerView.pause()
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
        self.playerView.isHasVolume = false
        self.playerView.pause()
        if self.cellConfigurators.count == 0 { return }
        let indexPath = IndexPath(item: self.index, section: 0)
        let configurator = self.cellConfigurators[self.index]
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if let cell = cell as? VideoCardCollectionViewCell,
                  let configurator = configurator as? CellConfigurator<VideoCardCollectionViewCell> {
            weak var weakSelf = self
            weak var weakCell = cell
            if let resource = playerView.resource,
               resource.definitions[0].url == configurator.viewModel.videoURL {
                playerView.seek(0) { [weak playerView] in
                    playerView?.play()
                }
                return
            }
            let resource = SweetPlayerResource(url: configurator.viewModel.videoURL)
            resource.indexPath = indexPath
            resource.scrollView = weakSelf?.collectionView
            resource.fatherViewTag = weakCell?.contentImageView.tag
            self.playerView.setVideo(resource: resource)
            self.avPlayer = self.playerView.avPlayer
        }
    }

    private func scrollCard(withPoint point: CGPoint) {
        guard let start = panPoint else { return }
        var direction = Direction.unknown
        if  start.y - point.y > 30 {
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
                self.preloadingCard()
                index += 1
                self.scrollTo(row: index)
            }
        } else if start.y - point.y >= 0 {
            self.scrollTo(row: index)
        } else if start.y - point.y < -30 {
            if index == 0 {
                self.scrollTo(row: index)
            } else {
                self.index -=  1
                self.scrollTo(row: index)
            }
        } else if start.y - point.y < 0 {
            self.scrollTo(row: index)
        }
    }
    
    private func preloadingCard() {
        if self.collectionView.numberOfItems(inSection: 0) - 1 - index < preloadingCount {
            logger.debug(cards[index].content ?? "")
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
        let preview = WebViewController(urlString: url)
        preview.title = card.content
        navigationController?.pushViewController(preview, animated: true)
    }
}
// MARK: - UICollectionViewDataSource
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
