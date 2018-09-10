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
import Reachability
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
    
    lazy var mainView: CardsPageCollectionView = {
        let view = CardsPageCollectionView()
        view.dataSoure = self
        view.delegate = self
        cotentOffsetToken = view.collectionView.observe(
            \.contentOffset,
            options: [.new, .old],
            changeHandler: { [weak self] (object, change) in
                guard let `self` = self else { return }
                if change.newValue == change.oldValue { return }
                if floor(object.contentOffset.y + cardInsetTop)  == floor(CGFloat(self.index) * cardCellHeight) {
                    if self.lastIndex == self.index { return }
                    self.changeCurrentCell()
                    self.lastIndex = self.index
                }
        })
        return view
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
    private var cotentOffsetToken: NSKeyValueObservation?
    private lazy var emptyView: EmptyEmojiView = {
        if self is CardsAllController {
            return EmptyEmojiView(image: #imageLiteral(resourceName: "AllEmptyEmoji"), title: "内容暂时没有了")
        } else {
            return EmptyEmojiView(image: #imageLiteral(resourceName: "EmptyEmoji"), title: "快去首页发现有趣的内容")
        }
    }()
    
    private var isFetchLoadCards = false
    private var isPreloadingCards = false
    private var avPlayer: AVPlayer?
    private var storage: Storage?
    private var reachability = Reachability()
    private var isWifi = false
    lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "可以带一句你想说的话"
        view.delegate = self
        return view
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        storage = Storage(userID: user.userId)
        view.backgroundColor = UIColor.xpGray()
        view.addSubview(mainView)
        mainView.fill(in: view)
        if #available(iOS 11.0, *) {
            mainView.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(downButton)
        downButton.constrain(width: 60, height: 60)
        downButton.align(.right, inset: 10)
        downButton.align(.bottom, inset: 10)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(note:)),
                                               name: .reachabilityChanged,
                                               object: reachability)
       try? reachability?.startNotifier()
        
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            sweetPlayerConf.shouldAutoPlay = true
            isWifi = true
        default:
            isWifi = false
            readSetting()
        }
    }
    
    private func readSetting() {
        storage?.read({ (realm) in
            guard let settingData = realm.object(ofType: SettingData.self, forPrimaryKey: self.user.userId) else { return }
            if self.isWifi {
                sweetPlayerConf.shouldAutoPlay = true
            } else {
                sweetPlayerConf.shouldAutoPlay = settingData.autoPlay
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readSetting()
        if let avPlayer = avPlayer, view.alpha != 0 {
            if let cell = mainView.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VideoCardCollectionViewCell {
                let autoPlay = sweetPlayerConf.shouldAutoPlay
                if let isPlaying = cell.playerView.avPlayer?.isPlaying {
                    sweetPlayerConf.shouldAutoPlay = isPlaying
                } else if let isPlaying = cell.playerView.savePlayer?.isPlaying {
                    sweetPlayerConf.shouldAutoPlay = isPlaying
                }
                cell.playerView.setAVPlayer(player: avPlayer)
                sweetPlayerConf.shouldAutoPlay = autoPlay
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = mainView.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VideoCardCollectionViewCell {
            cell.playerView.pauseWithRemove(isRemove: true)
        }
    }
    
    deinit {
        VideoCardPlayerManager.shared.clean()
        cotentOffsetToken?.invalidate()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        logger.debug("首页释放")
    }
    
    private func showEmptyView(isShow: Bool) {
        if isShow {
            if emptyView.superview != nil { return }
            mainView.addSubview(emptyView)
            if self is CardsAllController {
                if isFetchLoadCards {
                    emptyView.update(image: #imageLiteral(resourceName: "CardLoading"), title: "加载中")
                } else  {
                    emptyView.update(image: #imageLiteral(resourceName: "AllEmptyEmoji"), title: "内容暂时没有了")
                }
            }
            emptyView.frame = CGRect(x: 0,
                                     y: -10,
                                     width: mainView.bounds.width,
                                     height: mainView.bounds.height + 11)
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
    @objc private func didPressDownButton(_ sender: UIButton) {
        index = maxIndex
        mainView.scrollToIndex(index)
    }
}

// MARK: - Private
extension CardsBaseController {
    func startLoadCards(cardRequest: CardRequest,
                        callback: ((_ success: Bool, _ cards: [CardResponse]?) -> Void)? = nil) {
        if isFetchLoadCards {
            callback?(false, nil)
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
        let itemNumber = mainView.collectionView.numberOfItems(inSection: 0)
        let addCount = self.cards.count - itemNumber
        if addCount == 0 {
            callback?(true, nil)
            return
        }
        mainView.collectionView.performBatchUpdates({
            var items = [IndexPath]()
            for item in 0..<addCount {
                items.append(IndexPath(item: itemNumber + item, section: 0))
            }
            mainView.collectionView.insertItems(at: items)
        }, completion: { (_) in
            self.mainView.updatePageContentSize()
            callback?(true, cards)
        })
    }
    func changeCurrentCell() {
        if cellConfigurators.count == 0 { return }
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = mainView.collectionView.cellForItem(at: indexPath) else { return }
        self.saveLastId()
        let configurator = self.cellConfigurators[index]
        if let cell = cell as? VideoCardCollectionViewCell,
            let configurator = configurator as? CellConfigurator<VideoCardCollectionViewCell> {
            cell.playerView.delegate = self
            VideoCardPlayerManager.shared.play(with: configurator.viewModel.videoURL)
            let resource = SweetPlayerResource(url: configurator.viewModel.videoURL)
            resource.indexPath = indexPath
            cell.playerView.resource = resource
            cell.playerView.setAVPlayer(player: VideoCardPlayerManager.shared.player!)
            cell.playerView.isVideoMuted = isVideoMuted
            cell.playerView.seek(configurator.viewModel.currentTime) {
                cell.playerView.autoPlay()
            }
            avPlayer = VideoCardPlayerManager.shared.player!
        } else {
            for cell in mainView.collectionView.visibleCells {
                if let cell = cell as? VideoCardCollectionViewCell,
                    let indexPath = mainView.collectionView.indexPath(for: cell) {
                    let isCurrent = indexPath.item != index
                    cell.playerView.pauseWithRemove(isRemove: isCurrent)
                }
            }
            VideoCardPlayerManager.shared.pause()
        }
        
        if cell is ChoiceCardCollectionViewCell  {
            if Defaults[.isPreferenceGuideShown] == false {
                Guide.showPreference()
                Defaults[.isPreferenceGuideShown] = true
            }
        }
    }
    
    func videoPauseAddRemove() {
        for cell in mainView.collectionView.visibleCells {
            if let cell = cell as? VideoCardCollectionViewCell {
                cell.playerView.pauseWithRemove(isRemove: true)
            }
        }
    }

    private func downScrollCard(index: Int) {
        let maxIndex = mainView.collectionView.numberOfItems(inSection: 0) - 1
        if index <= maxIndex {
            self.index = index
        } else if index > maxIndex {
            self.index = maxIndex
            mainView.scrollToIndex(self.index)
        }
    }
    

    private func preloadingCard(oldIndex: Int) {
        if mainView.collectionView.numberOfItems(inSection: 0) - 1 - index < preloadingCount {
            let cardId = cards[oldIndex].cardId
            let content = cards[oldIndex].content
            let direction = Direction.down
            let request: CardRequest = self is CardsAllController ?
                .all(cardId: cardId, direction: direction) :
                .sub(cardId: cardId, direction: direction)
            let semaphore  = DispatchSemaphore(value: 0)
            let count = preloadingCount - (mainView.collectionView.numberOfItems(inSection: 0) - 1 - index)
            if isPreloadingCards { return }
            DispatchQueue.global().async {
                var isForEach = true
                self.isPreloadingCards = true
                for i in 0..<count {
                    logger.debug(i)
                    logger.debug(content ?? "")
                    if isForEach == false { break }
                    self.startLoadCards(cardRequest: request) { (success, _) in
                        if success {
                            semaphore.signal()
                        } else {
                            semaphore.signal()
                            isForEach = false
                        }
                    }
                    semaphore.wait()
                }
                self.isPreloadingCards = false
            }

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
// MARK: - CardsPageCollectionViewDataSource
extension CardsBaseController: CardsPageCollectionViewDataSource {
    func cardsPageCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        showEmptyView(isShow: cellConfigurators.count == 0)
        return cellConfigurators.count
    }
    
    func cardsPageCollectionView(
        _ collectionView: UICollectionView,
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
// MARK: - CardsPageCollectionViewDelegate
extension CardsBaseController: CardsPageCollectionViewDelegate {
    func cardsPageCollectionView(_ collectionView: UICollectionView, scrollToIndex index: Int, oldIndex: Int) {
        if index >= self.index {
            preloadingCard(oldIndex: oldIndex)
            downScrollCard(index: index)
        } else {
            self.index = index
        }
    }
    
    func cardsPageCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newIndex = indexPath.row
        if newIndex == index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VideoCardCollectionViewCell {
                showVideoPlayerController(playerView: cell.playerView, cardId: cards[index].cardId)
            } else if let _ = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ContentCardCollectionViewCell {
                showImageBrowser(selectedIndex: 0)
            } else {
                showWebView(indexPath: indexPath)
            }
        } else {
            index = newIndex
            mainView.scrollToIndex(index)
        }
    }
}
