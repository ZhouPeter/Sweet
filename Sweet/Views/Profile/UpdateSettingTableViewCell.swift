//
//  UpdateSettingTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol UpdateSettingTableViewCellDelegate: NSObjectProtocol {
    func changeSetting(isOn: Bool, cell: UpdateSettingTableViewCell)
}
class UpdateSettingTableViewCell: UITableViewCell {
    weak var delegate: UpdateSettingTableViewCellDelegate?
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var settingSwitch: UISwitch = {
        let view = UISwitch(frame: .zero)
        view.onTintColor = UIColor(hex: 0x36C6FD)
        view.addTarget(self, action: #selector(didSwitchChanged(_:)), for: .valueChanged)
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
    
    private func setupUI () {
        contentView.addSubview(descriptionLabel)
        descriptionLabel.align(.left, inset: 16)
        descriptionLabel.centerY(to: contentView)
        contentView.addSubview(settingSwitch)
        settingSwitch.centerY(to: contentView)
        settingSwitch.align(.right, inset: 8)
    }
    
    func update(description: String, isOpen: Bool) {
        descriptionLabel.text = description
        settingSwitch.isOn = isOpen
    }
    
    @objc private func didSwitchChanged(_ sender: UISwitch) {
        delegate?.changeSetting(isOn: sender.isOn, cell: self)
    }
 
}
