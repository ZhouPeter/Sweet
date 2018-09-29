//
//  GameCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import TapticEngine

class GameContentView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var infoMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.65)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ""))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        return imageView
    }()
    private lazy var infoTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
        
    }()
    
    private lazy var infoSubTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black.withAlphaComponent(0.35)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.textColor = UIColor(hex: 0xF4718D)
        label.text = "-- : --"
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: 0xF4718D)
        layer.cornerRadius = 10
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var titleLabelLayoutCenterYConstraint: NSLayoutConstraint?
    private var infoTitleLabelLayoutTopConstraint: NSLayoutConstraint?
    private var infoSubTitleLabelLayoutBottomConstraint: NSLayoutConstraint?

    private func setupUI() {
        addSubview(subTitleLabel)
        subTitleLabel.centerX(to: self)
        subTitleLabel.centerY(to: self, offset: -75 + titleLabel.font.lineHeight / 2)
        addSubview(titleLabel)
        titleLabel.centerX(to: self)
        titleLabelLayoutCenterYConstraint = titleLabel.centerY(to: self, offset: -75 - subTitleLabel.font.lineHeight / 2)
        addSubview(infoMaskView)
        infoMaskView.align(.bottom, inset: 30)
        infoMaskView.align(.left, inset: 20)
        infoMaskView.align(.right, inset: 20, priority: .defaultHigh)
        infoMaskView.constrain(height: 120)
        infoMaskView.addSubview(timeLabel)
        timeLabel.fill(in: infoMaskView)
        infoMaskView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 50, height: 50)
        avatarImageView.align(.left, inset: 20)
        avatarImageView.centerY(to: infoMaskView)
        avatarImageView.setViewRounded(borderWidth: 2, borderColor: .white)
        infoMaskView.addSubview(infoTitleLabel)
        infoTitleLabel.pin(.right, to: avatarImageView, spacing: 20)
        infoTitleLabel.align(.right, inset: 10)
        infoTitleLabelLayoutTopConstraint = infoTitleLabel.align(.top, to: avatarImageView)
        infoMaskView.addSubview(infoSubTitleLabel)
        infoSubTitleLabel.align(.left, to: infoTitleLabel)
        infoSubTitleLabel.align(.right, inset: 10)
        infoSubTitleLabelLayoutBottomConstraint = infoSubTitleLabel.align(.bottom, to: avatarImageView)
    }
    
    private func hiddenInfo(isHidden: Bool) {
        avatarImageView.isHidden = isHidden
        infoTitleLabel.isHidden = isHidden
        infoSubTitleLabel.isHidden = isHidden
        timeLabel.isHidden = !isHidden
    }
    
    func update(viewModel: GameCardViewModel) {
        hiddenInfo(isHidden: viewModel.isHiddenInfo)
        subTitleLabel.isHidden = viewModel.isHiddenLikeCount
        if subTitleLabel.isHidden {
            titleLabelLayoutCenterYConstraint?.constant = -75
        } else {
            titleLabelLayoutCenterYConstraint?.constant = -75 - subTitleLabel.font.lineHeight / 2
        }
        titleLabel.text = viewModel.resultTitleString
        subTitleLabel.text = viewModel.likeString
        if viewModel.isShowCompleteInfo {
            infoTitleLabel.text = viewModel.completeInfoString
            avatarImageView.sd_setImage(with: viewModel.avatarURL)
            infoTitleLabelLayoutTopConstraint?.constant = -10
            infoSubTitleLabelLayoutBottomConstraint?.constant = 10
        } else {
            infoTitleLabel.text = viewModel.simpleInfoString
            avatarImageView.image = UIImage(named: "AvatarPh")
            infoTitleLabelLayoutTopConstraint?.constant = 0
            infoSubTitleLabelLayoutBottomConstraint?.constant = 0
        }
        timeLabel.text = viewModel.timeString
        infoSubTitleLabel.text = viewModel.commentString
    }
    
}
protocol GameCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    func changeViewModel(_ viewModel: GameCardViewModel)
}

class GameCardCollectionViewCell: BaseCardCollectionViewCell, CellUpdatable, CellReusable {
    typealias ViewModelType = GameCardViewModel
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "GameBg"))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Help"), for: .normal)
        button.addTarget(self, action: #selector(didPressHelp(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    private lazy var playButtonBackgroudView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressProfile(_:)))
        gameContentInfoView.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0xF4718D)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("偷回去", for: .normal)
        button.layer.cornerRadius = 40
        return button
    }()
    
    private lazy var gameContentInfoView: GameContentView = {
        let view = GameContentView(frame: .zero)
        view.layer.cornerRadius = 10
     
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        customContent.insertSubview(backgroundImageView, belowSubview: titleLabel)
        backgroundImageView.fill(in: customContent)
        customContent.addSubview(helpButton)
        helpButton.centerY(to: titleLabel)
        helpButton.align(.right, to: customContent, inset: 10)
        helpButton.constrain(width: 40, height: 40)
        customContent.addSubview(gameContentInfoView)
        gameContentInfoView.align(.left, inset: 15)
        gameContentInfoView.align(.right, inset: 15)
        gameContentInfoView.pin(.bottom, to: titleLabel, spacing: 15)
        gameContentInfoView.align(.bottom, inset: 150)
        customContent.addSubview(playButtonBackgroudView)
        playButtonBackgroudView.constrain(width: 104, height: 104)
        playButtonBackgroudView.align(.bottom, inset: 25)
        playButtonBackgroudView.centerX(to: self)
        playButtonBackgroudView.setViewRounded()
        playButtonBackgroudView.addSubview(playButton)
        playButtonBackgroudView.layoutIfNeeded()
        playButton.frame = CGRect(x: 12,
                                  y: 12,
                                  width: playButtonBackgroudView.frame.width - 24,
                                  height: playButtonBackgroudView.frame.height - 24)
        
    }
    private var timer: DispatchSourceTimer?
    private var time: UInt64 = 0
    private var viewModel: GameCardViewModel?
    func updateWith(_ viewModel: GameCardViewModel) {
        menuButton.isHidden = true
        titleLabel.textColor = .white
        self.viewModel = viewModel
        gameContentInfoView.update(viewModel: viewModel)
        titleLabel.text = viewModel.titleString
        playButton.setTitle(viewModel.buttonTitleString, for: .normal)
        let offset: CGFloat = viewModel.isBigButton ? 7 : 12
        UIView.animate(withDuration: 0.5) {
            self.playButton.layer.cornerRadius = (self.playButtonBackgroudView.frame.width - offset * 2) / 2
            self.playButton.frame = CGRect(x: offset,
                                           y: offset,
                                           width: self.playButtonBackgroudView.frame.width - offset * 2,
                                           height: self.playButtonBackgroudView.frame.height - offset * 2)
        }
        setButtonSelector(buttonString: viewModel.buttonTitleString)
        changeViewModel()
    }
    
    private func changeViewModel() {
        if let delegate = delegate as? GameCardCollectionViewCellDelegate, let viewModel = self.viewModel {
            delegate.changeViewModel(viewModel)
        }
    }
    
    private func setButtonSelector(buttonString: String) {
        playButton.removeTarget(self, action: nil, for: .allEvents)
        gameContentInfoView.isUserInteractionEnabled = false
        playButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        if buttonString == "偷回去" {
            playButton.addTarget(self, action: #selector(didToPlay(_:)), for: .touchUpInside)
        } else if buttonString == "按住" || buttonString == "停" {
            playButton.addTarget(self, action: #selector(didPlayTouchDown(_:)), for: .touchDown)
            playButton.addTarget(self, action: #selector(didPlayTouchUp(_:)), for: .touchUpInside)
            playButton.addTarget(self, action: #selector(didPlayTouchUp(_:)), for: .touchUpOutside)
        } else if buttonString == "查看" {
            playButton.addTarget(self, action: #selector(didShowCompleteInfo(_:)), for: .touchUpInside)
        } else if buttonString == "访问主页" {
            playButton.addTarget(self, action: #selector(didShowProfile(_:)), for: .touchUpInside)
            playButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            gameContentInfoView.isUserInteractionEnabled = true
        }
        
    }
    
    @objc private func didPressProfile(_ tap: UITapGestureRecognizer) {
        viewModel?.showProfile?(viewModel!.userId)
    }
    
    @objc private func didPressHelp(_ sender: UIButton) {
        Guide.showGameHelpMessage()
        CardAction.clickHelp.actionLog(cardId: viewModel!.cardId)
    }
    
    @objc private func didToPlay(_ sender: UIButton) {
        guard var viewModel = self.viewModel else { return }
        viewModel.isHiddenInfo = true
        viewModel.isHiddenLikeCount = true
        viewModel.buttonTitleString = "按住"
        viewModel.isBigButton = false
        viewModel.timeString = "-- : --"
        viewModel.resultTitleString = "按出1秒 偷❤️×1"
        updateWith(viewModel)
    }
    
    @objc private func didShowCompleteInfo(_ sender: UIButton) {
        guard var viewModel = self.viewModel else { return }
        viewModel.isHiddenInfo = false
        viewModel.isHiddenLikeCount = true
        viewModel.isShowCompleteInfo = true
        viewModel.buttonTitleString = "访问主页"
        viewModel.isBigButton = false
        viewModel.resultTitleString =
"""
从\(viewModel.heOrSheString)偷❤️+1成功
👇👇👇
"""
        updateWith(viewModel)
    }
    @objc private func didShowProfile(_ sender: UIButton) {
            viewModel?.showProfile?(viewModel!.userId)
    }
    @objc private func didPlayTouchDown(_ sender: UIButton) {
        time = 0
        let queue = DispatchQueue.global()
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(wallDeadline: .now(), repeating: 0.01)
        timer?.setEventHandler {
            if self.time > 200 {
                DispatchQueue.main.async {
                    guard var viewModel = self.viewModel else { return }
                    viewModel.isHiddenInfo = true
                    viewModel.isHiddenLikeCount = true
                    viewModel.buttonTitleString = "停"
                    viewModel.isBigButton = true
                    viewModel.timeString = "请松开手指"
                    viewModel.resultTitleString = "按出1秒 偷❤️×1"
                    self.updateWith(viewModel)
                }
            } else {
                DispatchQueue.main.async {
                    guard var viewModel = self.viewModel else { return }
                    viewModel.isHiddenInfo = true
                    viewModel.isHiddenLikeCount = true
                    viewModel.buttonTitleString = "停"
                    viewModel.isBigButton = true
                    viewModel.timeString = self.time / 40 % 2 == 0 ? "--   --" : "-- : --"
                    viewModel.resultTitleString = "按出1秒 偷❤️×1"
                    self.updateWith(viewModel)
                }
            }
            self.time += 1
        }
        timer?.resume()
    }
    
    @objc private func didPlayTouchUp(_ sender: UIButton) {
        timer?.cancel()
        timer = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if  self.time >= 90 && self.time <= 110 {
                guard var viewModel = self.viewModel else { return }
                viewModel.isHiddenInfo = true
                viewModel.isHiddenLikeCount = true
                viewModel.buttonTitleString = "查看"
                viewModel.isBigButton = false
                viewModel.timeString = "\(self.time.toTimeString())"
                viewModel.resultTitleString = "偷❤️成功🎉"
                self.updateWith(viewModel)
                self.requestStealLike(isSuccess: true)
                if #available(iOS 10.0, *), self.traitCollection.forceTouchCapability == .available  {
                    TapticEngine.impact.feedback(.heavy)
                } else {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
            } else {
                guard var viewModel = self.viewModel else { return }
                viewModel.isHiddenInfo = true
                viewModel.isHiddenLikeCount = false
                viewModel.likeString = "按住0.9~1.1s内"
                viewModel.buttonTitleString = "按住"
                viewModel.isBigButton = false
                viewModel.timeString = "\(self.time.toTimeString())"
                viewModel.resultTitleString = "偷❤️失败"
                self.updateWith(viewModel)
                self.requestStealLike(isSuccess: false)
            }
        }
    }
    
    private func requestStealLike(isSuccess: Bool) {
        guard let viewModel = viewModel else { return }
        web.request(
            .stealLike(cardId: viewModel.cardId,
                       duration: time * 10,
                       success: isSuccess,
                       toUserId: viewModel.userId)) { (_) in }
    }
}

extension UInt64 {
    func toTimeString() -> String {
        let tenMillisecond = self
        let first =  String(format: "%02ld", tenMillisecond/100)
        let second = String(format: "%02ld", tenMillisecond%100)
        return first + " : " + second
    }
}


