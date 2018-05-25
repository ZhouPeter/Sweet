//
//  StoryKeyboardControlView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/22.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol StoryKeyboardControlViewDelegate: class {
    func keyboardControlViewDidPressNextButton()
    func keyboardControlViewDidPressTopicButton()
}

final class StoryKeyboardControlView: UIView {
    weak var delegate: StoryKeyboardControlViewDelegate?
    
    private lazy var topicButton: UIButton = {
        let button = UIButton(topic: "添加标签")
        button.addTarget(self, action: #selector(didPressTopicButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        let image = #imageLiteral(resourceName: "NextButton")
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 17), resizingMode: .stretch)
        button.setBackgroundImage(image, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        button.addTarget(self, action: #selector(didPressNextButton), for: .touchUpInside)
        return button
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setup() {
        addSubview(topicButton)
        addSubview(nextButton)
        topicButton.constrain(height: 30)
        topicButton.align(.left, to: self, inset: 20)
        topicButton.centerY(to: self)
        nextButton.constrain(height: 30)
        nextButton.align(.right, to: self, inset: 20)
        nextButton.align(.bottom, to: topicButton)
    }
    
    @objc private func didPressTopicButton() {
        delegate?.keyboardControlViewDidPressTopicButton()
    }
    
    @objc private func didPressNextButton() {
        delegate?.keyboardControlViewDidPressNextButton()
    }
}
