//
//  StoryCardView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

class StoryCardView: UIView {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
        return view
    }()
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "RightArrow")
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    var card: CardResponse?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(backgroundView)
        backgroundView.fill(in: self)
        addSubview(descLabel)
        descLabel.align(.left, inset: 15)
        descLabel.align(.right, inset: 15)
        descLabel.align(.top, inset: 15)
        addSubview(sourceLabel)
        sourceLabel.align(.left, to: descLabel)
        sourceLabel.pin(.bottom, to: descLabel, spacing: 10)
        addSubview(arrowImageView)
        arrowImageView.constrain(width: 16, height: 16)
        arrowImageView.centerY(to: sourceLabel)
        arrowImageView.pin(.right, to: sourceLabel, spacing: 5)
        addSubview(thumbnailImageView)
        thumbnailImageView.constrain(width: 60, height: 60)
        thumbnailImageView.align(.bottom, inset: 10)
        thumbnailImageView.align(.right, inset: 10)
    }
    
    func update(descString: String, thumbnailURL: URL) {
        descLabel.attributedText = descString.getAttributedString(lineSpacing: 4)
        thumbnailImageView.sd_setImage(with: thumbnailURL)
        sourceLabel.isHidden = true
        arrowImageView.isHidden = true
        card = nil
    }
    
    func update(card: CardResponse) {
        self.card = card
        sourceLabel.text = card.sourceEnumType?.getSourceText()
        sourceLabel.isHidden = false
        arrowImageView.isHidden = false
    }
    
}
