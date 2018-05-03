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
        let titles = ["动态", "小故事", "好友评价"]
        for index in 0 ..< 3 {
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
    
    lazy var placeholderView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.xpGray()
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
        delegate?.selectedAction(at: sender.tag)
    }
    
    private func setupUI() {
        let buttonWidth: CGFloat = (UIScreen.mainWidth() - CGFloat(buttons.count) - 1) / CGFloat(buttons.count)
        let buttonHeight: CGFloat = 49
        for (index, button) in buttons.enumerated() {
            contentView.addSubview(button)
            button.frame = CGRect(x: buttonWidth * CGFloat(index) + CGFloat(index),
                                  y: 0,
                                  width: buttonWidth,
                                  height: buttonHeight)
        }
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
