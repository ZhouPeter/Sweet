//
//  ConstellationCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/10/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
struct Constellation {
    let name: String
    let date: String
}

class ConstellationCell: UITableViewCell {
    private lazy var constellationNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: 0x9B9B9B)
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var selectedButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Selected"), for: .normal)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(constellationNameLabel)
        constellationNameLabel.align(.left, inset: 16)
        constellationNameLabel.centerY(to: contentView)
        contentView.addSubview(timeLabel)
        timeLabel.pin(.right, to: constellationNameLabel, spacing: 10)
        timeLabel.centerY(to: contentView)
        contentView.addSubview(selectedButton)
        selectedButton.constrain(width: 30, height: 30)
        selectedButton.align(.right, inset: 16)
        selectedButton.centerY(to: contentView)
    }
    
    
    func updateWith(_ constellation: Constellation, isSelected: Bool) {
        constellationNameLabel.text = constellation.name
        timeLabel.text = "(\(constellation.date))"
        selectedButton.isHidden = !isSelected
    }

}
