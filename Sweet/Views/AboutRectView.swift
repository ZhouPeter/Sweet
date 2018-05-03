//
//  AboutRectView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class AboutRectView: UIView {
    var clickCallBack: (() -> Void)?
    private lazy var roundedRectView: RoundedRectView = {
        let rectView = RoundedRectView()
        rectView.fillColor = .white
        rectView.shadowInsetX = 0
        rectView.shadowInsetY = 0
        rectView.cornerRadius = 25
        rectView.isShadowEnabled = true
        return rectView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        button.setTitle(title, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        clickCallBack?()
    }
    
    private func setupUI() {
        addSubview(roundedRectView)
        roundedRectView.fill(in: self)
        addSubview(button)
        button.fill(in: self)
    }
}
