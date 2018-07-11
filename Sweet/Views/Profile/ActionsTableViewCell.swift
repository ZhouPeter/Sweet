//
//  ActionSetTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ActionsTableViewCellDelegate: NSObjectProtocol {
    func selectedAction(at index: Int)
}
class ActionsTableViewCell: UITableViewCell {
    weak var delegate: ActionsTableViewCellDelegate?
    private lazy var buttons: [UIButton] = {
        var buttons = [UIButton]()
        let titles = ["动态", "小故事"]
        for index in 0 ..< titles.count {
            let button = UIButton()
            button.backgroundColor = .white
            button.setTitle(titles[index], for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitleColor(.black, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(selectAction(_:)), for: .touchUpInside)
            buttons.append(button)
        }
        buttons[0].titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return buttons
    }()
    private lazy var selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x5FC3FF)
        return view
    }()
    
    lazy var placeholderView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func selectAction(_ sender: UIButton) {
        buttons.forEach { (button) in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        let newX = 14 +  UIScreen.mainWidth() / CGFloat(self.buttons.count) * CGFloat(sender.tag)
        UIView.animate(withDuration: 0.2) {
            let transform = CGAffineTransform(translationX: newX - self.selectedView.frame.origin.x, y: 0)
            self.selectedView.transform = transform

        }
        selectedView.transform = .identity
        selectedView.frame = CGRect(x: newX,
                                    y: 48,
                                    width: UIScreen.mainWidth() / CGFloat(buttons.count) - 28,
                                    height: 2)
        delegate?.selectedAction(at: sender.tag)
    }
    
    private func setupUI() {
        let buttonWidth: CGFloat = UIScreen.mainWidth() / CGFloat(buttons.count)
        let buttonHeight: CGFloat = 48
        for (index, button) in buttons.enumerated() {
            contentView.addSubview(button)
            button.frame = CGRect(x: buttonWidth * CGFloat(index) + CGFloat(index),
                                  y: 0,
                                  width: buttonWidth,
                                  height: buttonHeight)
        }
        contentView.addSubview(selectedView)
        selectedView.frame = CGRect(x: 14,
                                    y: 48,
                                    width: UIScreen.mainWidth() / CGFloat(buttons.count) - 28,
                                    height: 2)
        contentView.addSubview(placeholderView)
        placeholderView.fill(in: contentView, top: 50)
    }
    
    func setPlaceholderContentView(view: UIView) {
        if placeholderView.superview != nil {
            placeholderView.removeFromSuperview()
        }
        placeholderView = view
        contentView.addSubview(placeholderView)
        placeholderView.fill(in: contentView, top: 50)
    }
}
