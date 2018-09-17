//
//  StoriesPlayerViewController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyUserDefaults
import Alamofire
import VIMediaCache
import Hero
import JDStatusBarNotification
import SDWebImage

protocol StoriesPlayerViewControllerDelegate: NSObjectProtocol {
    func playToBack()
    func playToNext()
    func dismissController()
    func delStory(storyId: UInt64)
    func updateStory(story: StoryCellViewModel, position: (Int, Int))
    func changeStatusBarHidden(isHidden: Bool, becomeAfter: Double)
}

extension StoriesPlayerViewControllerDelegate{
    func playToBack() {}
    func playToNext() {}
    func dismissController() {}
    func delStory(storyId: UInt64) {}
    func updateStory(story: StoryCellViewModel, position: (Int, Int)) {}
    func changeStatusBarHidden(isHidden: Bool, becomeAfter: Double) {}

}

class AVPlayerView: UIView {
    override class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
}
class StoriesPlayerViewController: UIViewController, StoriesPlayerView {
    var onFinish: (() -> Void)?
    var runStoryFlow: ((String) -> Void)?
    var runProfileFlow: ((UInt64) -> Void)?
    var isVisual = true
    var user: User
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerView: UIView!
    var playbackTimeObserver: Any?
    var statusToken: NSKeyValueObservation?
    var imageTimer: Timer?
    var timerNumber: Float = 0
    var photoBrowserImp: PhotoBrowserImp!

    var stories: [StoryCellViewModel]! {
        didSet {
            guard let stories = stories else { return }
            if stories.count == 0 {
            } else {
                if let IDString = Defaults[.userID], let userID = UInt64(IDString) {
                    self.isSelf = stories[0].userId == userID
                }
            }
        }
    }
    
    var currentIndex: Int = 0 {
        willSet {
            if let storiesScrollView = storiesScrollView {
                storiesScrollView.currentIndex = newValue
            }
        }
    }
    var groupIndex: Int = 0
    var fromCardId: String?
    weak var delegate: StoriesPlayerViewControllerDelegate?
    private var isSelf = true
    private var downloadBack: ((Bool) -> Void)?
    private var inputTextViewBottom: NSLayoutConstraint?
    private var inputTextViewHeight: NSLayoutConstraint?
    private var uvViewController: StoryUVController!
    private lazy var topContentView = UIView()
    private lazy var dismissButton: UIButton = {
        let dismissButton = UIButton()
        dismissButton.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissAction(sender:)), for: .touchUpInside)
        return dismissButton
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar(_:)))
        avatarImageView.addGestureRecognizer(tap)
        return avatarImageView
    }()
    
    private lazy var storyInfoLabel: UILabel = {
        let storyInfoLabel = UILabel()
        storyInfoLabel.numberOfLines = 0
        return storyInfoLabel
    }()
    
    private lazy var menuButton: UIButton = {
        let menuButton = UIButton()
        menuButton.setImage( #imageLiteral(resourceName: "Menu_white").withRenderingMode(.alwaysTemplate), for: .normal)
        menuButton.tintColor = .white
        if isSelf {
            menuButton.addTarget(self, action: #selector(presentSelfMenuAlertController(sender:)),
                                        for: .touchUpInside)
        } else {
            menuButton.addTarget(self, action: #selector(presentOtherMenuAlertController(sender:)),
                                        for: .touchUpInside)
        }
        return menuButton
    }()
    
    private lazy var progressView: StoryPlayProgressView = {
        let progressView = StoryPlayProgressView(count: stories.count, index: currentIndex)
        return progressView
    }()
    
    private lazy var commentLabel: InsetLabel = {
        let label = InsetLabel()
        label.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        label.font = UIFont.boldSystemFont(ofSize: 100)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.enableShadow()
        return label
    }()
    
    private lazy var cardView: StoryCardView = {
        let view = StoryCardView(frame: .zero)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressCardView(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var bottomButton: UIButton = {
        let bottomButton = UIButton()
        bottomButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        bottomButton.setTitleColor(.black, for: .normal)
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.backgroundColor = UIColor.white
        if isSelf {
            bottomButton.setImage(#imageLiteral(resourceName: "UvClose"), for: .normal)
            bottomButton.setImage(#imageLiteral(resourceName: "UvOpen"), for: .selected)
            bottomButton.addTarget(self, action: #selector(showStoryHistory(sender:)), for: .touchUpInside)
        } else {
            bottomButton.setImage(#imageLiteral(resourceName: "StoryUnLike"), for: .normal)
            bottomButton.setImage(#imageLiteral(resourceName: "StoryLike"), for: .disabled)
            bottomButton.addTarget(self, action: #selector(sendMessage(sender:)), for: .touchUpInside)
        }
        return bottomButton
    }()
    
    private lazy var pokeView: StoryPokeView = {
        let view = StoryPokeView()
        view.isHidden = true
        return view
    }()

    private var pokeLongPress: UILongPressGestureRecognizer!
    private var upPan: CustomPanGestureRecognizer!
    private var touchTagTap: TapGestureRecognizer!
    private lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "可以带一句你想说的话"
        view.delegate = self
        return view
    }()
    
    private lazy var maskView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    } ()
    
    var storiesScrollView: StoriesPlayerScrollView!
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGesture()
        view.clipsToBounds = true
        let frame = CGRect(x: 0,
                           y: UIScreen.safeTopMargin(),
                           width: view.bounds.width,
                           height: view.bounds.width * 16 / 9)
        storiesScrollView = StoriesPlayerScrollView(frame: frame)
        storiesScrollView.scrollViewTap.require(toFail: touchTagTap)
        view.addSubview(storiesScrollView)
        storiesScrollView.playerDelegate = self
        view.addSubview(pokeView)
        pokeView.frame = CGRect(origin: .zero, size: CGSize(width: 120, height: 120))
        setTopUI()
        setBottmUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name.StatusBarHidden, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name.StatusBarNoHidden, object: nil)

    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    private func setGesture() {
        pokeLongPress = UILongPressGestureRecognizer(target: self, action: #selector(pokeAction(longTap:)))
        view.addGestureRecognizer(pokeLongPress)
        upPan = CustomPanGestureRecognizer(orientation: .up, target: self, action: #selector(upPanAction(_:)))
        view.addGestureRecognizer(upPan)
        touchTagTap = TapGestureRecognizer(target: self, action: #selector(didPressTag(_:)))
        view.addGestureRecognizer(touchTagTap)
    }
    
    func update() {
        updateForStories()
        progressView.reset(count: stories.count, index: currentIndex)
    }

    private func setTopUI() {
        view.addSubview(topContentView)
        topContentView.align(.left)
        topContentView.align(.right)
        topContentView.align(.top, inset: UIScreen.safeTopMargin())
        topContentView.constrain(height: 70)
        topContentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.align(.left, inset: 10)
        avatarImageView.centerY(to: topContentView)
        avatarImageView.setViewRounded()
        topContentView.addSubview(dismissButton)
        dismissButton.constrain(width: 40, height: 40)
        dismissButton.align(.right, inset: 10)
        dismissButton.centerY(to: avatarImageView)
        topContentView.addSubview(progressView)
        progressView.align(.left)
        progressView.align(.right)
        progressView.align(.top, inset: 4)
        progressView.constrain(height: 5)
        topContentView.addSubview(storyInfoLabel)
        storyInfoLabel.pin(.right, to: avatarImageView, spacing: 5)
        storyInfoLabel.centerY(to: avatarImageView)
        topContentView.addSubview(menuButton)
        menuButton.constrain(width: 40, height: 40)
        menuButton.pin(.left, to: dismissButton, spacing: 15)
        menuButton.centerY(to: avatarImageView)
    
    }
    
    private func setBottmUI() {
        view.addSubview(bottomButton)
        bottomButton.centerX(to: view)
        bottomButton.align(.bottom, to: view, inset: 25)
        bottomButton.constrain(width: 50, height: 50)
        bottomButton.setViewRounded()
        view.addSubview(cardView)
        cardView.align(.left, inset: 10)
        cardView.align(.right, inset: 10)
        cardView.constrain(height: 160)
        cardView.pin(.top, to: bottomButton, spacing: 35)
        view.addSubview(commentLabel)
        commentLabel.align(.left, inset: 10)
        commentLabel.align(.right, inset: 10)
        commentLabel.pin(.top, to: cardView, spacing: 40)
        commentLabel.align(.top, inset: UIScreen.safeTopMargin() + 70)
    }
    
    private func updateUserData() {
        if let stories = stories {
            let avatarURL = stories[currentIndex].avatarURL
            avatarImageView.sd_setImage(with: avatarURL)
            let name = stories[currentIndex].nickname
            let subtitle = stories[currentIndex].subtitle
            setStoryInfoAttribute(name: name, timestampString: "", subtitle: subtitle)
            if isSelf {
                bottomButton.isSelected = false
                if stories[currentIndex].newReadCount == 0 {
                    bottomButton.setImage(#imageLiteral(resourceName: "UvClose"), for: .normal)
                    bottomButton.setTitle("", for: .normal)
                } else {
                    bottomButton.setImage(nil, for: .normal)
                    bottomButton.setTitle("+\(stories[currentIndex].newReadCount)", for: .normal)
                }
            } else {
                bottomButton.isEnabled = !stories[currentIndex].like
                bottomButton.setImage(#imageLiteral(resourceName: "StoryUnLike"), for: .normal)
            }
        }
    }
    
    private func setStoryInfoAttribute(name: String, timestampString: String, subtitle: String) {
        let string = "\(name) \(timestampString)" + (subtitle != "" ? "\n\(subtitle)" : "")
        let attributeString = NSMutableAttributedString(string: string)
        attributeString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)],
                                      range: NSRange(location: 0, length: name.utf16.count))
        attributeString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)],
                                      range: NSRange(location: name.utf16.count + 1,
                                                     length: timestampString.utf16.count))
        attributeString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)],
                                      range: NSRange(location: attributeString.length - subtitle.utf16.count,
                                                     length: subtitle.utf16.count))
        attributeString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.white],
                                      range: NSRange(location: 0, length: attributeString.length))
        storyInfoLabel.attributedText = attributeString
    }
    
    private func updateForStories() {
        updateUserData()
        storiesScrollView.updateForStories(stories: stories, currentIndex: currentIndex)
        updatePokeView()
        updateTouchTag()
        updateShareConcentUI()
    }
    
    private func updateShareConcentUI() {
        if stories[currentIndex].type == .share {
            let descString = stories[currentIndex].descString
            let commentString = stories[currentIndex].commentString
            let thumbnailURL = stories[currentIndex].imageURL
            cardView.update(descString: descString!, thumbnailURL: thumbnailURL!)
            commentLabel.text = commentString
            cardView.isHidden = false
            commentLabel.isHidden = commentString == nil || commentString == ""
            if let cardId = stories[currentIndex].fromCardId, cardId != "" {
                web.request(
                    .getCard(cardID: cardId),
                    responseType: Response<CardGetResponse>.self) { (result) in
                    switch result {
                    case let .success(response):
                        self.cardView.update(card: response.card)
                    case let .failure(error):
                        logger.error(error)
                    }
                }
            }
            
        } else {
            cardView.isHidden = true
            commentLabel.isHidden = true
        }
    }
    private func updatePokeView() {
        if stories[currentIndex].type == .poke {
            pokeView.isHidden = false
            let width = view.frame.width
            let height = width * 16 / 9
            let center = stories[currentIndex].pokeCenter
            pokeView.center = CGPoint(
                x: width * (0.5 + center.x),
                y: height * ( 0.5 + center.y) + UIScreen.safeTopMargin()
            )
            pokeLongPress.isEnabled = true
        } else {
            pokeView.isHidden = true
            pokeLongPress.isEnabled = false
        }
    }
    private func updateTouchTag() {
        if let path = stories[currentIndex].touchPath, runStoryFlow != nil {
            touchTagTap.isEnabled = true
            touchTagTap.path = path
            if Defaults[.isStoryTagGuideShown] == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let guide = Guide.showPlayTagTip(with: path)
                    guide.removeClosure = {
                        self.play()
                    }
                    self.pause()
                }
                Defaults[.isStoryTagGuideShown] = true
            }
        } else {
            touchTagTap.isEnabled = false
        }
    }
    
    func initPlayer() {
        if let videoURL = stories[currentIndex].videoURL {
            let resource = SweetPlayerResource(url: videoURL)
            let asset = resource.definitions[0]
            playerItem = AVPlayerItem(asset: asset.avURLAsset)
            player = AVPlayer(playerItem: playerItem)
            if #available(iOS 10.0, *) {
                player?.automaticallyWaitsToMinimizeStalling = false
            }
            player?.actionAtItemEnd = .none
            if playerView == nil {
                let frame = CGRect(x: 0,
                                   y: UIScreen.safeTopMargin(),
                                   width: view.bounds.width,
                                   height: view.bounds.width * 16 / 9)
                playerView = AVPlayerView(frame: frame)
                playerView.backgroundColor = .black
                if UIScreen.isNotched() {
                    playerView.layer.cornerRadius = 7
                    playerView.clipsToBounds = true
                }
                playerView.isUserInteractionEnabled = false
                view.insertSubview(playerView, belowSubview: pokeView)
            }
            playerView.isHidden = false
            view.backgroundColor = .black
            (playerView.layer as! AVPlayerLayer).player = player
            addVideoObservers()
            addKVOObservers()
        }
        player?.seek(to: CMTimeMakeWithSeconds(0.01, 1000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        play()
    }

    func reloadPlayer() {
        closePlayer()
        if stories.count - 1 < currentIndex {
            delegate?.playToNext()
        } else {
            updateForStories()
            initPlayer()
        }
    }
    
    func closePlayer() {
        if playerItem != nil {
            removeVideoObservers()
            removeKVOObservers()
            removePlayTimeObserver()
            player?.currentItem?.cancelPendingSeeks()
            player?.currentItem?.asset.cancelLoading()
            player?.replaceCurrentItem(with: nil)
//            playerView.removeFromSuperview()
            playerItem = nil
//            playerView = nil
            player = nil
            playerView.isHidden = true
        } else {
            imageReset()
        }
    }
    
    deinit {
        removeVideoObservers()
        removeKVOObservers()
        removePlayTimeObserver()
        removeImageTimer()
    }

}

extension StoriesPlayerViewController: InputTextViewDelegate {
    func inputTextViewDidPressSendMessage(text: String) {
        play()
        inputTextView.clear()
        inputTextView.removeFromSuperview()
        sendMessage(text: text, userIds: [stories[currentIndex].userId], like: true)
    }
    
    func removeInputTextView() {
        play()
        inputTextView.clear()
        inputTextView.removeFromSuperview()
    }
    
}
extension Timer {
    fileprivate class func scheduledTimer(timeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: block)
        } else {
            return Timer.scheduledTimer(timeInterval: timeInterval,
                                        target: self,
                                        selector: #selector(blcokInvoke(timer:)),
                                        userInfo: block,
                                        repeats: repeats)
        }
    }
    @objc private class func blcokInvoke(timer: Timer) {
        if let block = timer.userInfo as? (Timer) -> Void {
            block(timer)
        }
    }
}
// MARK: - ImageTimer Methods
extension StoriesPlayerViewController {
    private func removeImageTimer() {
        if imageTimer != nil {
            imageTimer?.invalidate()
            imageTimer = nil
        }
    }
    @objc private func imageTimeDown() {
        timerNumber += 1.0 / 60.0
        if timerNumber >= 3 {
            imageTimer?.invalidate()
            imageTimer = nil
            currentStoryPlayEnd()
        }
        let ratio = timerNumber / 3
        progressView.setProgress(ratio: CGFloat(ratio), index: currentIndex)
    }
    
    private func imagePause() {
        imageTimer?.invalidate()
        imageTimer = nil
    }
    
    private func imagePlay() {
        removeImageTimer()
        imageTimer = Timer.scheduledTimer(timeInterval: 1.0/60.0, repeats: true, block: { [weak self] (_) in
            self?.imageTimeDown()
        })
    }
    
    private func imageReset() {
        timerNumber = 0
        imageTimer?.invalidate()
        imageTimer = nil
    }
   
}

// MARK: - Privates
extension StoriesPlayerViewController {

    private func currentStoryPlayEnd() {
        if currentIndex == stories.count - 1 {
            delegate?.playToNext()
            return
        }
        currentIndex += 1
        reloadPlayer()
    }
    private func sendMessage() {
        pause()
        let window = UIApplication.shared.keyWindow!
        window.addSubview(inputTextView)
        inputTextView.fill(in: window)
        inputTextView.startEditing(isStarted: true)
    }
    private func showStoryHistory() {
        pause()
        topContentView.isHidden = true
        bottomButton.isSelected = true
        let storyId = stories[currentIndex].storyId
        uvViewController = StoryUVController(storyId: storyId, user: user)
        uvViewController.runProfileFlow = runProfileFlow
        uvViewController.delegate = self
        add(childViewController: uvViewController, addView: false)
        uvViewController.view.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: view.bounds.height - 100))
        view.addSubview(uvViewController.view)
        uvViewController.view.tag = 100
        stories[currentIndex].newReadCount = 0
        bottomButton.setImage(#imageLiteral(resourceName: "UvClose"), for: .normal)
        bottomButton.setTitle("", for: .normal)
        delegate?.updateStory(story: stories[currentIndex], position: (groupIndex, currentIndex))

    }
    func play() {
        for subview in view.subviews {
            if subview.tag == 100 { return }
        }
        let storyId = stories[currentIndex].storyId
        web.request(.storyRead(storyId: storyId, fromCardId: fromCardId)) { (result) in
            switch result {
            case .success:
                if let index = self.stories.index(where: {$0.storyId == storyId}) {
                    self.stories[index].read = true
                    self.delegate?.updateStory(story: self.stories[index], position: (self.groupIndex, self.currentIndex))
                }
            case .failure: break
            }
        }
        if stories[currentIndex].videoURL != nil && stories[currentIndex].type != .poke {
            player?.play()
        } else if stories[currentIndex].imageURL != nil {
            imagePlay()
        }
    }
    
    func pause() {
        if stories.count - 1 < currentIndex { return }
        if stories[currentIndex].videoURL != nil {
            player?.pause()
        } else if stories[currentIndex].imageURL != nil {
            imagePause()
        }
    }
}

// MARK: - Actions
extension StoriesPlayerViewController {
    @objc private func didPressCardView(_ tap: UITapGestureRecognizer) {
        if let card = cardView.card {
            pause()
            if let video = card.video, let videoURL = URL(string: video) {
                let asset = SweetPlayerManager.assetNoCache(for: videoURL)
                let playerItem = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: playerItem)
                let controller = PlayController()
                controller.avPlayer = player
                controller.resource = SweetPlayerResource(url: videoURL)
                present(controller, animated: true, completion: nil)
            } else if let imageList = card.imageList {
                let imageURLs = imageList.compactMap { URL(string: $0)}
                photoBrowserImp = PhotoBrowserImp(highImageViewURLs: imageURLs)
                let browser = CustomPhotoBrowser(delegate: photoBrowserImp,
                                                 photoLoader: SDWebImagePhotoLoader(),
                                                 originPageIndex: 0)
                browser.animationType = .fade
                browser.plugins.append(CustomNumberPageControlPlugin())
                browser.show()
            } else if let url = card.url {
                let webController = WebViewController(urlString: url)
                webController.finish = { [weak self] in
                    self?.play()
                }
                navigationController?.pushViewController(webController, animated: true)
            }
        } else {
            if let url = stories[currentIndex].urlString, Defaults[.review] == 0 {
                pause()
                let webController = WebViewController(urlString: url)
                webController.finish = { [weak self] in
                    self?.play()
                }
                navigationController?.pushViewController(webController, animated: true)
            }
        }
        
    }
    @objc private func didTapAvatar(_ tap: UITapGestureRecognizer) {
        runProfileFlow?(stories[currentIndex].userId)
    }
    
    @objc private func didPressTag(_ tap: UITapGestureRecognizer) {
        let topic = stories[currentIndex].tag
        runStoryFlow?(topic)
    }
    
    @objc private func pokeAction(longTap: UILongPressGestureRecognizer) {
        switch longTap.state {
        case .began:
            self.player?.play()
            self.pokeView.isHidden = true
        case .ended:
            self.pause()
            self.pokeView.isHidden = false
        default: break
        }
    }
    
    @objc private func upPanAction(_ gesture: CustomPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let progress = translation.y / view.bounds.height
        switch gesture.state {
        case .began: break
        case .changed: break
        default:
            if progress + gesture.velocity(in: nil).y / view.bounds.height < -0.3 {
                if isSelf == false {
                    sendMessage()
                }
            }
        }
    }
    
    @objc private func dismissAction(sender: UIButton) {
        dismiss()
    }
    
    @objc private func showStoryHistory(sender: UIButton) {
        if sender.isSelected {
            closeStoryUV()
        } else {
            showStoryHistory()
        }
    }
    
    @objc private func sendMessage(sender: UIButton) {
        sendMessage()
    }
    
    @objc private func presentSelfMenuAlertController(sender: UIButton) {
        pause()
        let alertController = UIAlertController()
        let shareAction = UIAlertAction.makeAlertAction(title: "分享给联系人", style: .default) { [weak self] (_) in
            guard let `self` = self else { return }
            let controller = ShareCardController()
            controller.sendCallback = { (text, userIds) in
                self.sendMessage(text: text, userIds: userIds)
            }
            self.present(controller, animated: true, completion: nil)
        }
        alertController.addAction(shareAction)
        let downloadAction = UIAlertAction.makeAlertAction(title: "保存到手机", style: .default) { [weak self] (_) in
            guard let `self` = self else { return }
            self.play()
            self.downloadStory(downloadBack: { (isSuccess) in
                self.toast(message: isSuccess ? "保存成功" : "保存失败")
            })
        }
        alertController.addAction(downloadAction)
        let delAction = UIAlertAction.makeAlertAction(title: "删除本条", style: .default) { [weak self] (_) in
            guard let `self` = self else { return }
            let alertController = UIAlertController(title: "删除本条小故事",
                                                    message: "删除的小故事将无法恢复",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { [weak self](_) in
                self?.play()
            })
            let delAction = UIAlertAction(title: "删除", style: .destructive, handler: { [weak self] (_) in
                guard let `self` = self else { return }
                self.deleteStory(storyId: self.stories[self.currentIndex].storyId)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(delAction)
            self.present(alertController, animated: true, completion: nil)
        }
        alertController.addAction(delAction)
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel) { [weak self] (_) in
            self?.play()
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func presentOtherMenuAlertController(sender: UIButton) {
        self.pause()
        let userId = stories[currentIndex].userId
        let storyId = stories[currentIndex].storyId
        web.request(WebAPI.userStatus(userId: userId), responseType: Response<StatusResponse>.self) { [weak self] (result) in
            switch result {
            case let .success(response):
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertController.addAction(
                    UIAlertAction.makeAlertAction(title: "分享给联系人",
                                                  style: .default,
                                                  handler: { [weak self] (_) in
                    let controller = ShareCardController()
                    controller.sendCallback = { [weak self] (text, userIds) in
                        self?.sendMessage(text: text, userIds: userIds)
                    }
                    self?.present(controller, animated: true, completion: nil)
                }))
                alertController.addAction(UIAlertAction.makeAlertAction(
                    title: response.subscription ? "取消订阅" : "订阅该用户",
                    style: .default,
                    handler: { (_) in
                        if response.subscription {
                            web.request(.delUserSubscription(userId: userId), completion: { (result) in
                                self?.delegate?.changeStatusBarHidden(isHidden: false, becomeAfter: 2)
                                switch result {
                                case .success:
                                    JDStatusBarNotification.show(withStatus: "取消订阅成功", dismissAfter: 2)
                                case .failure:
                                    JDStatusBarNotification.show(withStatus: "取消订阅失败，请稍后重试。", dismissAfter: 2)
                                }
                            })
                        } else {
                            web.request(.addUserSubscription(userId: userId), completion: { (result) in
                                self?.delegate?.changeStatusBarHidden(isHidden: false, becomeAfter: 2)
                                switch result {
                                case .success:
                                    JDStatusBarNotification.show(withStatus: "订阅成功", dismissAfter: 2)
                                case .failure:
                                    JDStatusBarNotification.show(withStatus: "订阅失败，请稍后重试。", dismissAfter: 2)
                                }
                            })
                        }
                }))
                let blockAction = UIAlertAction.makeAlertAction(
                    title: response.block ? "取消屏蔽" : "屏蔽该用户",
                    style: .default,
                    handler: { (_) in
                        if response.block {
                            web.request(.delBlock(userId: userId), completion: { (result) in
                                self?.delegate?.changeStatusBarHidden(isHidden: false, becomeAfter: 2)
                                switch result {
                                case .success:
                                    JDStatusBarNotification.show(withStatus: "取消屏蔽成功", dismissAfter: 2)
                                case .failure:
                                    JDStatusBarNotification.show(withStatus: "取消屏蔽失败，请稍后重试。", dismissAfter: 2)
                                }
                            })
                        } else {
                            web.request(.addBlock(userId: userId), completion: { (result) in
                                self?.delegate?.changeStatusBarHidden(isHidden: false, becomeAfter: 2)
                                switch result {
                                case .success:
                                    JDStatusBarNotification.show(withStatus: "屏蔽成功", dismissAfter: 2)
                                case .failure:
                                    JDStatusBarNotification.show(withStatus: "屏蔽失败，请稍后重试。", dismissAfter: 2)
                                }
                            })
                        }
                })
                alertController.addAction(blockAction)
                let reportAction = UIAlertAction.makeAlertAction(title: "投诉", style: .default, handler: { (_) in
                    web.request(.reportStory(storyId: storyId), completion: { (result) in
                        self?.delegate?.changeStatusBarHidden(isHidden: false, becomeAfter: 2)
                        switch result {
                        case .success:
                            JDStatusBarNotification.show(withStatus: "投诉成功", dismissAfter: 2)
                        case .failure:
                            JDStatusBarNotification.show(withStatus: "投诉失败，请稍后重试。", dismissAfter: 2)
                        }
                    })
                })
                alertController.addAction(reportAction)
                alertController.addAction(
                    UIAlertAction.makeAlertAction(title: "取消", style: .cancel){ [weak self] (_) in
                        self?.play()
                    }
                )
                self?.present(alertController, animated: true, completion: nil)
            case let .failure(error):
                logger.error(error)
            }
        }
       
    }
    
    private func dismiss() {
        if self.presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        if self.parent is UINavigationController {
            onFinish?()
        } else {
            delegate?.dismissController()
        }
    }
    
    private func deleteStory(storyId: UInt64) {
        web.request(
            .delStory(storyId: storyId),
            completion: { [weak self] (result) in
                guard let `self` = self else { return }
                self.play()
                switch result {
                case .success:
                    self.toast(message: "删除成功")
                    self.delegate?.delStory(storyId: self.stories[self.currentIndex].storyId)
                    self.stories.remove(at: self.currentIndex)
                    if self.currentIndex > self.stories.count - 1 {
                        self.currentIndex = max(self.currentIndex - 1, 0)
                    }
                    self.progressView.reset(count: self.stories.count, index: self.currentIndex)
                    self.reloadPlayer()
                case let .failure(error):
                    logger.error(error)
                }
        })
    }
    
    private func sendMessage(text: String, userIds: [UInt64], like: Bool = false) {
        let storyId = stories[currentIndex].storyId
        let from = UInt64(Defaults[.userID]!)!
        let storyType = stories[currentIndex].type
        var url: String = ""
        if storyType == .video || storyType == .poke {
            url = stories[currentIndex].videoURL!.absoluteString
        } else if storyType == .text || storyType == .image || storyType == .share {
            url = stories[currentIndex].imageURL!.absoluteString
        } else {
            return
        }
        let content = StoryMessageContent(identifier: storyId, storyType: storyType, url: url)
        userIds.forEach {
            Messenger.shared.sendStory(content, from: from, to: $0, extra: fromCardId)
            if like { waitingIMNotifications.append(Messenger.shared.sendLike(from: from, to: $0, extra: fromCardId))  }
            if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: fromCardId) }
            if like {
                web.request(
                    WebAPI.likeStory(storyId: storyId, comment: text, fromCardId: fromCardId),
                    completion: { result in
                        switch result {
                        case .success:
                            self.bottomButton.isEnabled = false
                            self.stories[self.currentIndex].like = true
                            self.delegate?.updateStory(story: self.stories[self.currentIndex],
                                                       position: (self.groupIndex, self.currentIndex))
                            if let cardId = self.fromCardId {
                                CardAction.likeStory.actionLog(cardId: cardId, storyId: String(storyId))
                            }
                        case .failure: break
                        }
                })
            } else {
                web.request(.shareStory(storyId: storyId, comment: text, userId: $0, fromCardId: fromCardId),
                            completion: {_ in })
            }
        }
        NotificationCenter.default.post(name: .dismissShareCard, object: nil)
    }
}

// MARK: - downloadStory
extension StoriesPlayerViewController {
    private func downloadStory(downloadBack: @escaping (Bool) -> Void) {
        self.downloadBack = downloadBack
        if  let videoURL = stories[currentIndex].videoURL {
            downloadVideo(url: videoURL)
        } else if  stories[currentIndex].imageURL != nil {
            downloadImage(image: storiesScrollView.middleImageView.image!)
        }
    }
    
    private func downloadImage(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    private func downloadVideo(url: URL) {
        let manager = SessionManager.default
        let downloadRequest: DownloadRequest
        if url.scheme == "file" {
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
                UISaveVideoAtPathToSavedPhotosAlbum(url.path,
                                                    self,
                                                    #selector(video(_:didFinishSavingWithError:contextInfo:)),
                                                    nil)
            }
            return
        }
        let request = URLRequest(url: url)
        var fileURL: URL?
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            fileURL = URL.videoCacheURL(withName: response.suggestedFilename!)
            return (fileURL!, [.removePreviousFile, .createIntermediateDirectories])
        }

        downloadRequest = manager.download(request, to: destination)
        downloadRequest.responseData { (response) in
            switch response.result {
            case .success:
                if let fileURL = fileURL, UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileURL.path) {
                    UISaveVideoAtPathToSavedPhotosAlbum(fileURL.path,
                                                        self,
                                                    #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                        nil)
                }
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    @objc private func image(_ image: UIImage?,
                             didFinishSavingWithError error: Error?,
                             contextInfo: UnsafeMutableRawPointer?) {
        downloadBack?(error == nil)
    }
    
    @objc private func video(_ videoPath: String?,
                             didFinishSavingWithError error: Error?,
                             contextInfo: UnsafeMutableRawPointer?) {
        downloadBack?(error == nil)
    }
}
// MARK: - addObservers && removeObservers
extension StoriesPlayerViewController {
    private  func addVideoObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveToEnd(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(backGroundPauseMoive(_:)),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
    }

    private func removeVideoObservers() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc func moveToEnd(_ noti: Notification) {
        guard let object = noti.object,
            let item = object as? AVPlayerItem,
            item == playerItem else { return }
       currentStoryPlayEnd()
    }
    
    @objc func backGroundPauseMoive(_ noti: Notification) {
        pause()
    }
    
    private func addKVOObservers() {
        statusToken = playerItem?.observe(\.status, options: [.new], changeHandler: { [weak self] (_, _) in
            self?.playItemStatusChange()
        })
    }
    
    private func removeKVOObservers() {
       statusToken?.invalidate()
    }
    
    private func removePlayTimeObserver() {
        if let playbackTimeObserver = playbackTimeObserver {
            player?.removeTimeObserver(playbackTimeObserver)
            self.playbackTimeObserver = nil
        }
    }
    
    private func playItemStatusChange() {
        if let status = playerItem?.status {
            switch status {
            case .readyToPlay:
                if let value = playerItem?.duration.value, let scale = playerItem?.duration.timescale {
                    let totalSecond = Double(value) / Double(scale)
                    monitoringPlayback(totalSecond: totalSecond)
                }
            default: break
            }
        }
    }
    
    private func monitoringPlayback(totalSecond: Double) {
        playbackTimeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(value: CMTimeValue(1.0),
            timescale: CMTimeScale(60.0)),
            queue: DispatchQueue(label: "player.time.queue"),
            using: { [weak self] _ in
                guard let `self` = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    if let value = self.playerItem?.currentTime().value,
                        let scale = self.playerItem?.currentTime().timescale {
                        let currentSecond = Double(value) / Double(scale)
                        if totalSecond == 0 {
                            self.progressView.setProgress(ratio: 0, index: self.currentIndex)
                        } else {
                            let ratio = currentSecond / totalSecond
                            self.progressView.setProgress(ratio: CGFloat(ratio) > 0 ? CGFloat(ratio) : 0,
                                                          index: self.currentIndex)
                        }
                    }
                }
        })
    }

}
// MARK: - StoryUVControllerDelegate
extension StoriesPlayerViewController: StoryUVControllerDelegate {
    func closeStoryUV() {
        uvViewController.willMove(toParentViewController: nil)
        uvViewController.view.removeFromSuperview()
        uvViewController.removeFromParentViewController()
        topContentView.isHidden = false
        bottomButton.isSelected = false
        play()
    }
}
// MARK: - StoriesPlayerScrollViewDelegate
extension StoriesPlayerViewController: StoriesPlayerScrollViewDelegate {
    func playToBack() {
        delegate?.playToBack()
    }

    func playToNext() {
        delegate?.playToNext()
    }

    func playScrollView(scrollView: StoriesPlayerScrollView, currentPlayerIndex: Int) {
        pause()
        currentIndex = currentPlayerIndex
        progressView.setProgress(ratio: 0, index: currentIndex)
        reloadPlayer()
    }
}
