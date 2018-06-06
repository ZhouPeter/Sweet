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
@objc protocol StoriesPlayerViewControllerDelegate: NSObjectProtocol {
    @objc optional func playToBack()
    @objc optional func playToNext()
    @objc optional func dismissController()
    @objc optional func delStory(withStoryId storyId: Int)
}
class StoriesPlayerViewController: BaseViewController {
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    var playbackTimeObserver: Any?
    var statusToken: NSKeyValueObservation?
    var imageTimer: Timer?
    var timerNumber: Float = 0
    var stories: [StoryCellViewModel]! {
        didSet {
            self.isSelf = stories[0].userId == UInt64(Defaults[.userID] ?? "0")
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
    weak var delegate: StoriesPlayerViewControllerDelegate?
    private  var downloadBack: ((Bool) -> Void)?
    private var inputTextViewBottom: NSLayoutConstraint?
    private var inputTextViewHeight: NSLayoutConstraint?
    private lazy var dismissButton: UIButton = {
        let dismissButton = UIButton()
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissAction(sender:)), for: .touchUpInside)
        return dismissButton
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        return avatarImageView
    }()
    
    private lazy var storyInfoLabel: UILabel = {
        let storyInfoLabel = UILabel()
        storyInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        storyInfoLabel.numberOfLines = 0
        return storyInfoLabel
    }()
    
    private lazy var menuButton: UIButton = {
        let menuButton = UIButton()
        menuButton.translatesAutoresizingMaskIntoConstraints = false
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
            bottomButton.setImage( #imageLiteral(resourceName: "History"), for: .normal)
            bottomButton.addTarget(self, action: #selector(openStoryHistory(sender:)), for: .touchUpInside)
        } else {
            bottomButton.setImage( #imageLiteral(resourceName: "Heart_White"), for: .normal)
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
//    private lazy var inputTextView: InputBottomView = {
//        let view = InputBottomView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.delegate = self
//        view.sendButton.setImage(#imageLiteral(resourceName: "HeartRed"), for: .normal)
//        view.shouldSendNilText = true
//        view.placeHolder = "带句好听的话吧~"
//        return view
//    } ()
    
    private lazy var maskView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    } ()
    
    private var storiesScrollView: StoriesPlayerScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        storiesScrollView = StoriesPlayerScrollView(frame: CGRect(x: 0,
                                                                  y: 0,
                                                                  width: UIScreen.mainWidth(),
                                                                  height: UIScreen.mainHeight()))
        view.addSubview(storiesScrollView)
        storiesScrollView.playerDelegate = self
        setTopUI()
        view.addSubview(pokeView)
        pokeView.frame = CGRect(origin: .zero, size: CGSize(width: 120, height: 120))
        setBottmUI()
        setUserData()
        updateForStories(stories: stories, currentIndex: currentIndex)
//        addInputTextView()
 
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setTopUI() {
        view.addSubview(avatarImageView)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.align(.left, to: view, inset: 10)
        avatarImageView.align(.top, to: view, inset: UIScreen.isIphoneX() ? 44 + 15 : 15)
        avatarImageView.setViewRounded()
        view.addSubview(dismissButton)
        dismissButton.constrain(width: 30, height: 30)
        dismissButton.align(.right, to: view, inset: 10)
        dismissButton.centerY(to: avatarImageView)
        view.addSubview(progressView)
        progressView.align(.left, to: view)
        progressView.align(.right, to: view)
        progressView.align(.top, to: view, inset: UIScreen.isIphoneX() ? 48 : 4)
        progressView.constrain(height: 5)
        view.addSubview(storyInfoLabel)
        storyInfoLabel.pin(.right, to: avatarImageView, spacing: 5)
        storyInfoLabel.centerY(to: avatarImageView)
        view.addSubview(menuButton)
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
        storiesScrollView.updateForStories(stories: stories, currentIndex: currentIndex)
        if stories[currentIndex].type == .poke {
            pokeView.isHidden = false
            pokeView.frame = CGRect(origin: stories[currentIndex].pokeCenter, size: CGSize(width: 120, height: 120))
            pokeLongPress = UILongPressGestureRecognizer(target: self, action: #selector(pokeAction(longTap:)))
            view.addGestureRecognizer(pokeLongPress)
        } else {
            pokeView.isHidden = true
            if let pokeLongPress = pokeLongPress {
                view.removeGestureRecognizer(pokeLongPress)
            }
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
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.frame = view.bounds
            view.layer.insertSublayer(playerLayer!, below: avatarImageView.layer)
            addVideoObservers()
            addKVOObservers()
        }
        play()
        observeKeyboard()
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
            playerItem = nil
            playerLayer?.removeFromSuperlayer()
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

extension Timer {
    fileprivate class func scheduledTimer(timeInterval: TimeInterval, repeats: Bool, block: (Timer) -> Void) -> Timer {
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
    
//    private func addInputTextView() {
//        view.addSubview(maskView)
//        maskView.fill(in: view)
//        maskView.alpha = 0
//        maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMaskView)))
//        view.addSubview(inputTextView)
//        inputTextView.align(.left, to: view)
//        inputTextView.align(.right, to: view)
//        inputTextViewHeight = inputTextView.constrain(height: InputBottomView.defaultHeight())
//        inputTextViewBottom = inputTextView.align(.bottom, to: view, inset: -InputBottomView.defaultHeight())
//        view.layoutIfNeeded()
//    }
    
    private func observeKeyboard() {
//        NotificationCenter.default
//            .addObserver(self, selector: #selector(keyboardWillShowWith(_:)), name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default
//            .addObserver(self, selector: #selector(keyboardWillHideWith(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func didTapMaskView() {
//        inputTextView.startEditing(false)
    }
    
//    @objc private func keyboardWillShowWith(_ note: Notification) {
//        guard
//            let info = note.userInfo,
//            let keyboardSizeValue = info[UIKeyboardFrameEndUserInfoKey] as? NSValue,
//            let durationValue = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
//            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as? UInt
//            else { return }
//        pause()
//        inputTextViewBottom?.constant = -keyboardSizeValue.cgRectValue.height
//        UIView.animate(
//            withDuration: durationValue.doubleValue,
//            delay: 0,
//            options: UIViewAnimationOptions(rawValue: curve),
//            animations: {
//                self.maskView.alpha = 1
//                self.view.layoutIfNeeded()
//        },
//            completion: nil)
//    }
//    
//    @objc private func keyboardWillHideWith(_ note: Notification) {
//        guard
//            let info = note.userInfo,
//            let durationValue = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
//            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as? UInt
//            else { return }
//        play()
//        inputTextViewBottom?.constant = InputBottomView.defaultHeight()
//        UIView.animate(
//            withDuration: durationValue.doubleValue,
//            delay: 0,
//            options: UIViewAnimationOptions(rawValue: curve),
//            animations: {
//                self.maskView.alpha = 0
//                self.view.layoutIfNeeded()
//        },
//            completion: nil)
//    }

    private func currentStoryPlayEnd() {
        if currentIndex == stories.count - 1 {
            delegate?.playToNext?()
            return
        }
        currentIndex += 1
        reloadPlayer()
    }
    
    func play() {
//        XPClient.reportReadStory(withStoryId: stories[currentIndex].storyId, completion: nil)
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
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            delegate?.dismissController?()
        }
    }
    
    @objc private func openStoryHistory(sender: UIButton) {
        let storyId = stories[currentIndex].storyId
        let uvViewController = StoryUVController(storyId: storyId)
        pause()
        uvViewController.delegate = self
        addChildViewController(uvViewController)
        uvViewController.didMove(toParentViewController: self)
        guard let childView = uvViewController.view else { return }
        view.tag = 100
        view.addSubview(childView)
        uvViewController.view.frame = view.bounds
    }
    
    @objc private func sendMessage(sender: UIButton) {
//        inputTextView.startEditing(true)
    }
    
    @objc private func presentSelfMenuAlertController(sender: UIButton) {
        pause()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "分享给联系人", style: .default) { (_) in
            let controller = ShareCardController()
            controller.sendCallback = { (text, userIds) in
                self.sendMessage(text: text, userIds: userIds)
            }
            self.present(controller, animated: true, completion: nil)
        }
        alertController.addAction(shareAction)
        let downloadAction = UIAlertAction(title: "保存到手机", style: .default) { [weak self] (_) in
            guard let `self` = self else { return }
            self.play()
            self.downloadStory(downloadBack: { (isSuccess) in
                self.toast(message: isSuccess ? "保存成功" : "保存失败", duration: 2)
            })
        }
        alertController.addAction(downloadAction)
        let delAction = UIAlertAction(title: "删除本条", style: .default) { [weak self] (_) in
            guard let `self` = self else { return }
            let alertController = UIAlertController(title: "删除本条小故事",
                                                    message: "删除的小故事将无法恢复",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: { [weak self](_) in
                self?.play()
            })
            let delAction = UIAlertAction.init(title: "删除", style: .destructive, handler: { [weak self] (_) in
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(delAction)
            self.present(alertController, animated: true, completion: nil)
        }
        delAction.setValue(UIColor.black, forKey: "_titleTextColor")
        alertController.addAction(delAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { [weak self] (_) in
            self?.play()
        }
        alertController.addAction(cancelAction)
        let popover = alertController.popoverPresentationController
        popover?.sourceView = view
        popover?.sourceRect = view.bounds
        popover?.permittedArrowDirections = .any
        present(alertController, animated: true, completion: nil)
    }

    @objc private func presentOtherMenuAlertController(sender: UIButton) {
        self.pause()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "分享给联系人", style: .default, handler: { (_) in
            let controller = ShareCardController()
            controller.sendCallback = { (text, userIds) in
                self.sendMessage(text: text, userIds: userIds)
            }
            self.present(controller, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "订阅该用户", style: .default, handler: { (_) in
            
        }))
        let blockAction = UIAlertAction(title: "屏蔽", style: .default, handler: { (_) in
            
        })
        blockAction.setValue(UIColor.black, forKey: "_titleTextColor")
        alertController.addAction(blockAction)
        let reportAction = UIAlertAction(title: "投诉", style: .default, handler: { (_) in
            
        })
        reportAction.setValue(UIColor.black, forKey: "_titleTextColor")
        alertController.addAction(reportAction)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func sendMessage(text: String, userIds: [UInt64]) {
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
        let content = StoryMessageContent(storyType: storyType, url: url)
        userIds.forEach {
            Messenger.shared.sendStory(content, from: from, to: $0)
            if text != "" { Messenger.shared.sendText(text, from: from, to: $0) }
        }
//        NotificationCenter.default.post(name: .dismissShareCard, object: nil)
    
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
        guard let downloadBack = downloadBack else { return }
        if error != nil {
            downloadBack(false)
        } else {
            downloadBack(true)
        }
    }
    
    @objc private func video(_ videoPath: String?,
                             didFinishSavingWithError error: Error?,
                             contextInfo: UnsafeMutableRawPointer?) {
        guard let downloadBack = downloadBack else { return }
        if error != nil {
            downloadBack(false)
        } else {
            downloadBack(true)
        }
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
                logger.debug("readyToPlay")
                if let value = playerItem?.duration.value, let scale = playerItem?.duration.timescale {
                    let totalSecond = Double(value) / Double(scale)
                    monitoringPlayback(totalSecond: totalSecond)
                }
            case .failed:
                logger.debug("failed")
                logger.debug(playerItem?.error ?? "")
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
                DispatchQueue.main.async {
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
        play()
    }
}
// MARK: - StoriesPlayerScrollViewDelegate
extension StoriesPlayerViewController: StoriesPlayerScrollViewDelegate {
    func playToBack() {
        delegate?.playToBack?()
    }

    func playToNext() {
        delegate?.playToNext?()
    }

    func playScrollView(scrollView: StoriesPlayerScrollView, currentPlayerIndex: Int) {
        pause()
        currentIndex = currentPlayerIndex
        progressView.setProgress(ratio: 0, index: currentIndex)
        reloadPlayer()
    }
}
//extension StoriesPlayerViewController: InputBottomViewDelegate {
//    func inputBottomViewDidChangeHeight(_ height: CGFloat) {
//        inputTextViewHeight?.constant = height + InputBottomView.verticalInset() * 2
//        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
//            self.view.layoutIfNeeded()
//        }, completion: nil)
//    }
//
//    func inputBottomViewDidPressSend(withText text: String?) {
//        guard let text = text else { return }
//        XPClient.likeStory(storyId: stories[currentIndex].storyId, fromText: text) { [weak self] (_, error) in
//            guard  error == nil else {
//                let hud = MBProgressHUD.showAdded(to: self!.view, animated: true)
//                hud.mode = .text
//                hud.label.text = "点赞失败"
//                hud.hide(animated: true)
//                return
//            }
//            guard let `self` = self else { return }
//            self.inputTextView.startEditing(false)
//        }
//    }
//}
