//
//  VideoDetailViewController.swift
//  MMFinancialSchool
//
//  Created by Alfred on 2017/4/22.
//  Copyright © 2017年 linweibiao. All rights reservevar//

import UIKit
import AVKit
import AVFoundation

class VideoDetailViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!

    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown]
    }
    
    // MARK: - PlayerControl
    var videoId = ""
    var videoIdLog = ""//日志里记录的video_id和视频播放纪录里的Key
    
    var url = "" {
        didSet {
            videoView.videoIdLog = videoIdLog
            videoView.url = url
        }
    }
    var filePath = "" {
        didSet {
            videoView.videoIdLog = videoIdLog
            videoView.filePath = filePath
        }
    }
    
    @IBOutlet weak var controlVView: ControlVView! {
        didSet {
            controlVView.alpha = CGFloat(0)
        }
    }
    
    @IBOutlet weak var controlHView: ControlHView! {
        didSet {
            controlHView.isHidden = true
            controlHView.alpha = CGFloat(0)
        }
    }

    @IBAction func fristPlayHidden(_ sender: UIButton) {
        allowRotation = true
        playButton.isHidden = true
        playURL("https://devstreaming-cdn.apple.com/videos/wwdc/2017/703muvahj3880222/703/hls_vod_mvp.m3u8")
    }
    
    enum PlayType {
        case play, noLogin, nopay
    }
    
    func playURL(_ urlString: String) {
        //  如果有封面加播放器应该放这里
        videoView.fatherView = videoBackgroundView
        videoView.holdImage = UIImage.init(named: "NetWaiting")
        url = urlString
        videoView.playerPub.play()
    }
    
    var isPlaying = false {
        didSet {
            if isPlaying == true {
                controlHView.playAndPauseButton.isSelected = true
                controlVView.playAndPauseButton.isSelected = true
            } else {
                controlHView.playAndPauseButton.isSelected = false
                controlVView.playAndPauseButton.isSelected = false
            }
        }
    }
    
    @IBAction func playAndPause() {
        if isPlaying == true {
            videoView.playerPub.pause()
            isPlaying = false
        } else {
            videoView.playerPub.play()
            isPlaying = true
        }
    }

    @IBOutlet weak var videoView: VideoPlayerView!
    @IBOutlet weak var videoBackgroundView: UIView! {
        didSet {
            videoView.frame = videoBackgroundView.bounds
        }
    }
    // MARK: - ControlViewGestures
    @IBOutlet weak var tapGestureRecognizerOneTappes: UITapGestureRecognizer!
    @IBAction func videoViewOneTap(_ sender: UITapGestureRecognizer) {
        if playButton.isHidden == true {
            controlVView.frame = videoBackgroundView.bounds
            var alpha = CGFloat(0.50)
            if self.controlVView.alpha == CGFloat(0.50) {
                alpha = 0
            }
            UIView.animate(withDuration: 0.6) {
                self.controlVView.alpha = CGFloat(alpha)
                self.controlHView.alpha = CGFloat(alpha)
            }
        }
    }
    
    @IBOutlet weak var tapGestureRecognizerTwoTappes: UITapGestureRecognizer! {
        didSet {
            tapGestureRecognizerOneTappes.require(toFail: tapGestureRecognizerTwoTappes)
        }
    }
    @IBAction func videoViewTwoTappes(_ sender: UITapGestureRecognizer) {
        playAndPause()
    }
    
    // MARK: - life
    @IBAction func backNav(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allowRotation = false
        playButton.isHidden = false
        controlVView.fullScreenButton.isSelected = false
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        allowRotation = false
        videoView.playerPub.pause()
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    deinit {
        videoView.removeFromSuperview()
    }

}
