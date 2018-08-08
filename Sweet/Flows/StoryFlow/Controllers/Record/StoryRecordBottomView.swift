//
//  StoryRecordBottomView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/22.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

private let buttonWidth: CGFloat = 70
private let buttonSpacing: CGFloat = 10

enum StoryRecordType: Int {
    case text
    case record
    case album
}

protocol StoryRecordBottomViewDelegate: class {
    func bottomViewDidPressTypeButton(_ type: StoryRecordType)
}

final class StoryRecordBottomView: UIView {
    weak var delegate: StoryRecordBottomViewDelegate?
    var isIndicatorHidden = false {
        didSet {
            indicator.isHidden = isIndicatorHidden
        }
    }
    private var buttons = [UIButton]()
    private let indicator = UIImageView(image: #imageLiteral(resourceName: "ArrowIndicator"))
    private var indicatorCenterX: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        selectBottomButton(at: 1, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setup() {
        let textButton = makeButton(withTitle: "文字", tag: 0, action: #selector(didPressBottomButton(_:)))
        let shootButton = makeButton(withTitle: "拍摄", tag: 1, action: #selector(didPressBottomButton(_:)))
        let albumButton = makeButton(withTitle: "相册", tag: 2, action: #selector(didPressBottomButton(_:)))
        addSubview(textButton)
        addSubview(shootButton)
        addSubview(albumButton)
        let height: CGFloat = 40
        textButton.constrain(width: buttonWidth, height: height)
        shootButton.constrain(width: buttonWidth, height: height)
        albumButton.constrain(width: buttonWidth, height: height)
        shootButton.center(to: self)
        textButton.pin(.left, to: shootButton, spacing: buttonSpacing)
        textButton.centerY(to: shootButton)
        albumButton.pin(.right, to: shootButton, spacing: buttonSpacing)
        albumButton.centerY(to: shootButton)
        buttons.append(textButton)
        buttons.append(shootButton)
        buttons.append(albumButton)
        
        addSubview(indicator)
        indicator.constrain(width: 8, height: 8)
        indicator.pin(.bottom, to: shootButton, spacing: -5)
        indicatorCenterX = indicator.centerX(to: shootButton)
    }
    
    private func makeButton(withTitle title: String, tag: Int, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func didPressBottomButton(_ button: UIButton) {
        selectBottomButton(at: button.tag, animated: true)
        guard let type = StoryRecordType(rawValue: button.tag) else { return }
        delegate?.bottomViewDidPressTypeButton(type)
    }
    
    func selectBottomButton(at index: Int, animated: Bool) {
        indicatorCenterX?.constant = CGFloat(index - 1) * (buttonWidth + buttonSpacing)
        if animated {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            UIView.setAnimationCurve(.easeOut)
        }
        buttons.enumerated().forEach { (offset, button) in
            button.alpha = offset == index ? 1 : 0.5
        }
        layoutIfNeeded()
        if animated {
            UIView.commitAnimations()
        }
    }
}
