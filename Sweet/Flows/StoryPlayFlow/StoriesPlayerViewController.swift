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
protocol StoriesPlayerViewControllerDelegate: NSObjectProtocol {
    func playToBack()
    func playToNext()
    func dismissController()
    func delStory(storyId: UInt64)
    func updateStory(story: StoryCellViewModel, position: (Int, Int))
}

extension StoriesPlayerViewControllerDelegate{
    func playToBack() {}
    func playToNext() {}
    func dismissController() {}
    func delStory(storyId: UInt64) {}
    func updateStory(story: StoryCellViewModel, position: (Int, Int)) {}
}

class AVPlayerView: UIView {
    override class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
}
class StoriesPlayerViewController: BaseViewController, StoriesPlayerView {
    var onFinish: (() -> Void)?
    var runStoryFlow: ((String) -> Void)?
    var runProfileFlow: ((User, UInt64) -> Void)?
    var pan: UIPanGestureRecognizer?
    var isVisual = true
    var user: User
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerView: UIView!
    var playbackTimeObserver: Any?
    var statusToken: NSKeyValueObservation?
    var imageTimer: Timer?
    var timerNumber: Float = 0
  
    var stories: [StoryCellViewModel]! {
        didSet {
            if stories.count == 0 {
                delegate?.dismissController()
            } else {
                self.isSelf = stories[0].userId == UInt64(Defaults[.userID] ?? "0")
            }
        }
    }
    
    private var isSelf = true
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
    private var downloadBack: ((Bool) -> Void)?
    private var inputTextViewBottom: NSLayoutConstraint?
    private var inputTextViewHeight: NSLayoutConstraint?
    private lazy var topContentView: UIView = {
        let view = UIView()
        return view
    }()
    
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
    
    private lazy var bottomButton: UIButton = {
        let bottomButton = UIButton()
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        if isSelf {
            bottomButton.setImage(#imageLiteral(resourceName: "History"), for: .normal)
            bottomButton.addTarget(self, action: #selector(openStoryHistory(sender:)), for: .touchUpInside)
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
    
    private lazy var tagButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.isHidden = true
        button.addTarget(self, action: #selector(didPressTag(_:)), for: .touchUpInside)
        return button
    }()

    private var pokeLongPress: UILongPressGestureRecognizer!
    private lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "说点有意思的"
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
        pokeLongPress = UILongPressGestureRecognizer(target: self, action: #selector(pokeAction(longTap:)))
        view.addGestureRecognizer(pokeLongPress)
        view.clipsToBounds = true
        storiesScrollView = StoriesPlayerScrollView(frame: CGRect(x: 0,
                                                                  y: 0,
                                                                  width: UIScreen.mainWidth(),
                                                                  height: UIScreen.mainHeight()))
        view.addSubview(storiesScrollView)
        storiesScrollView.fill(in: view)
        storiesScrollView.playerDelegate = self
        view.addSubview(pokeView)
        pokeView.frame = CGRect(origin: .zero, size: CGSize(width: 120, height: 120))
        view.addSubview(tagButton)
        setTopUI()
        setBottmUI()
        update()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.post(name: Notification.Name.StatusBarHidden, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name.StatusBarNoHidden, object: nil)

    }
    
    func update() {
        updateForStories(stories: stories, currentIndex: currentIndex)
        progressView.reset(count: stories.count, index: currentIndex)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
        dismissButton.constrain(width: 30, height: 30)
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
        menuButton.constrain(width: 30, height: 30)
        menuButton.pin(.left, to: dismissButton, spacing: 15)
        menuButton.centerY(to: avatarImageView)
    
    }
    
    private func setBottmUI() {
        view.addSubview(bottomButton)
        bottomButton.centerX(to: view)
        bottomButton.align(.bottom, to: view, inset: UIScreen.isIphoneX() ? 25 + 34 : 25)
        bottomButton.constrain(width: 50, height: 50)
        bottomButton.layoutIfNeeded()
        bottomButton.setViewRounded()
    }
    
    private func setUserData() {
        if let stories = stories {
            let avatarURL = stories[currentIndex].avatarURL
            avatarImageView.kf.setImage(with: avatarURL)
            let name = stories[currentIndex].nickname
            let subtitle = stories[currentIndex].subtitle
            setStoryInfoAttribute(name: name, timestampString: "", subtitle: subtitle)
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
    
    private func updateForStories(stories: [StoryCellViewModel], currentIndex: Int) {
        setUserData()
        bottomButton.isEnabled = !stories[currentIndex].like
        storiesScrollView.updateForStories(stories: stories, currentIndex: currentIndex)
        if stories[currentIndex].type == .poke {
            pokeView.isHidden = false
            pokeView.center = CGPoint(x: view.frame.width / 2 + stories[currentIndex].pokeCenter.x * view.frame.width,
                                      y: view.frame.height / 2 + stories[currentIndex].pokeCenter.y * view.frame.height)
            pokeLongPress.isEnabled = true
        } else {
            pokeView.isHidden = true
            pokeLongPress.isEnabled = false
        }
        if let touchArea = stories[currentIndex].touchArea {
            tagButton.isHidden = false
            tagButton.frame = touchArea
            if stories[currentIndex].userId == user.userId {
                tagButton.isHidden = true
            }
        } else {
            tagButton.isHidden = true
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
            playerView = AVPlayerView(frame: view.bounds)
            playerView.backgroundColor = .black
            view.backgroundColor = .black
            (playerView.layer as! AVPlayerLayer).player = player
            playerView.isUserInteractionEnabled = false
            view.insertSubview(playerView, belowSubview: pokeView)
            addVideoObservers()
            addKVOObservers()
        }
        player?.seek(to: CMTimeMakeWithSeconds(0.01, 1000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        play()
    }

    func reloadPlayer() {
        closePlayer()
        updateForStories(stories: stories, currentIndex: currentIndex)
        initPlayer()
    }
    
    func closePlayer() {
        if playerItem != nil {
            removeVideoObservers()
            removeKVOObservers()
            removePlayTimeObserver()
            player?.currentItem?.cancelPendingSeeks()
            player?.currentItem?.asset.cancelLoading()
            player?.replaceCurrentItem(with: nil)
            playerView.removeFromSuperview()
            playerItem = nil
            playerView = nil
            player = nil
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
       return  self.scheduledTimer(timeInterval: timeInterval,
                            target: self,
                            selector: #selector(blcokInvoke(timer:)),
                            userInfo: block,
                            repeats: repeats)
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
    
    func play() {
        web.request(.storyRead(storyId: stories[currentIndex].storyId, fromCardId: nil)) { (_) in }
        if stories[currentIndex].videoURL != nil && stories[currentIndex].type != .poke {
            player?.play()
        } else if stories[currentIndex].imageURL != nil {
            imagePlay()
        }
    }
    
    func pause() {
        if stories[currentIndex].videoURL != nil {
            player?.pause()
        } else if stories[currentIndex].imageURL != nil {
            imagePause()
        }
    }
}

// MARK: - Actions
extension StoriesPlayerViewController {
    
    @objc private func didTapAvatar(_ tap: UITapGestureRecognizer) {
        runProfileFlow?(user, stories[currentIndex].userId)
    }
    
    @objc private func didPressTag(_ sender: UIButton) {
        if stories[currentIndex].userId != user.userId {
            let topic = stories[currentIndex].tag
            runStoryFlow?(topic)
        }
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
    
    @objc private func dismissAction(sender: UIButton) {
        dismiss()
    }
    
    @objc private func openStoryHistory(sender: UIButton) {
        pause()
        topContentView.isHidden = true
        let storyId = stories[currentIndex].storyId
        let uvViewController = StoryUVController(storyId: storyId, user: user)
        uvViewController.runProfileFlow = runProfileFlow
        uvViewController.delegate = self
        addChildViewController(uvViewController)
        uvViewController.didMove(toParentViewController: self)
        guard let childView = uvViewController.view else { return }
        view.tag = 100
        view.addSubview(childView)
        uvViewController.view.frame = view.bounds
    }
    
    @objc private func sendMessage(sender: UIButton) {
        pause()
        let window = UIApplication.shared.keyWindow!
        window.addSubview(inputTextView)
        inputTextView.fill(in: window)
        inputTextView.startEditing(isStarted: true)
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
                self.toast(message: isSuccess ? "保存成功" : "保存失败", duration: 2)
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
                            web.request(.delUserSubscription(userId: userId), completion: { (_) in })
                        } else {
                            web.request(.addUserSubscription(userId: userId), completion: { (_) in })
                        }
                }))
                let blockAction = UIAlertAction.makeAlertAction(
                    title: response.block ? "取消屏蔽" : "屏蔽该用户",
                    style: .default,
                    handler: { (_) in
                        if response.block {
                            web.request(.delBlock(userId: userId), completion: { (_) in })
                        } else {
                            web.request(.addBlock(userId: userId), completion: { (_) in })
                        }
                })
                alertController.addAction(blockAction)
                let reportAction = UIAlertAction.makeAlertAction(title: "投诉", style: .default, handler: { (_) in
                    web.request(.reportStory(storyId: storyId), completion: { (_) in })
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
                        self.currentIndex -= 1
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
        } else if storyType == .text || storyType == .image {
            url = stories[currentIndex].imageURL!.absoluteString
        } else {
            return
        }
        let content = StoryMessageContent(identifier: storyId, storyType: storyType, url: url)
        userIds.forEach {
            Messenger.shared.sendStory(content, from: from, to: $0, extra: fromCardId)
            if like { Messenger.shared.sendLike(from: from, to: $0, extra: fromCardId)}
            if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: fromCardId) }
            if like {
                web.request(
                    WebAPI.likeStory(storyId: storyId, comment: text, fromCardId: fromCardId),
                    completion: { result in
                        switch result {
                        case .success:
                            self.vibrateFeedback()
                            self.bottomButton.isEnabled = false
                            self.stories[self.currentIndex].like = true
                            self.delegate?.updateStory(story: self.stories[self.currentIndex],
                                                       position: (self.groupIndex, self.currentIndex))
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
        topContentView.isHidden = false
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
