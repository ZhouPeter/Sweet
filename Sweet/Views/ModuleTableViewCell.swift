//
//  ModuleTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ModuleTableViewCell: UITableViewCell {
    private lazy var moduleImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var moduleTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "ContactSelected"), for: .selected)
        button.setBackgroundImage(#imageLiteral(resourceName: "ContactUnSelected"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(moduleImageView)
        moduleImageView.align(.left, inset: 16)
        moduleImageView.centerY(to: contentView)
        moduleImageView.constrain(width: 40, height: 40)
        contentView.addSubview(moduleTitleLabel)
        moduleTitleLabel.pin(.right, to: moduleImageView, spacing: 10)
        moduleTitleLabel.centerY(to: moduleImageView)
        contentView.addSubview(selectButton)
        selectButton.constrain(width: 22, height: 22)
        selectButton.centerY(to: contentView)
        selectButton.align(.right, inset: 12)
    }
    
    func update(image: UIImage, text: String, isCanSelected: Bool = false) {
        moduleImageView.image = image
        moduleTitleLabel.text = text
        selectButton.isHidden = !isCanSelected
    }
    
    func addDateOnImage() {
        let date = Date()
        let timestampString = TimerHelper.timeToMonthDay(timeInterval: date.timeIntervalSince1970)
        let attributedString = NSMutableAttributedString(string: timestampString)
        attributedString.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)],
                                       range: NSRange(location: 0, length: 2))
        let monthLength = attributedString.length - 3
        attributedString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8)],
                                       range: NSRange(location: 3, length: monthLength))
        let timeLabel = UILabel()
        timeLabel.backgroundColor = .white
        timeLabel.textAlignment = .center
        timeLabel.layer.cornerRadius = 2
        timeLabel.layer.masksToBounds = true
        timeLabel.numberOfLines = 2
        timeLabel.attributedText = attributedString
        moduleImageView.addSubview(timeLabel)
        timeLabel.fill(in: moduleImageView, left: 4, right: 4, top: 4, bottom: 4)
    }
}
