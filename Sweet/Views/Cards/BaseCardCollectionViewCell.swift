//
//  CardBaseCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol BaseCardCollectionViewCellDelegate: NSObjectProtocol {
    func showAlertController(cardId: String, fromCell: BaseCardCollectionViewCell)
}
class BaseCardCollectionViewCell: UICollectionViewCell {
    weak var delegate: BaseCardCollectionViewCellDelegate?
    var cardId: String?
    lazy var customContent: RoundedRectView = {
        let view = RoundedRectView()
        view.isShadowEnabled = true
        view.shadowInsetX = 0
        view.shadowInsetY = 0
        view.cornerRadius = 10
        view.shadowOpacity = 0.2
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Menu_black").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(hex: 0x9b9b9b)
        button.addTarget(self, action: #selector(menuAction(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseUI()
    }
    
    override var isSelected: Bool {
        set {}
        get { return super.isSelected }
    }
    
    override var isHighlighted: Bool {
        set {}
        get { return super.isHighlighted }
    }
    
    @objc private func menuAction(_ sender: UIButton) {
        if let cardId = cardId {
            delegate?.showAlertController(cardId: cardId, fromCell: self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.customContent.shrinkAnimation(scale: 0.95, duration: 0.5, damping: 1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        self.customContent.recoverAnimation(duration: 0.3, damping: 1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.customContent.recoverAnimation(duration: 0.3, damping: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBaseUI() {
        contentView.backgroundColor = UIColor.xpGray()
        contentView.addSubview(customContent)
        customContent.fill(in: contentView, left: 10, right: 10, top: 10, bottom: 10)
        customContent.addSubview(titleLabel)
        titleLabel.align(.left, to: customContent, inset: 10)
        titleLabel.align(.top, to: customContent, inset: 15)
        customContent.addSubview(menuButton)
        menuButton.centerY(to: titleLabel)
        menuButton.align(.right, to: customContent, inset: 10)
        menuButton.constrain(width: 30, height: 30)
    }
}
