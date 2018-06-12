//
//  TopicSearchCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/12.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TopicSearchCell: UITableViewCell {
    var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("添加", for: .normal)
        button.setTitleColor(UIColor(hex: 0x9B9B9B), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setBackgroundImage(#imageLiteral(resourceName: "AddTopic"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "AddTopicDisabled"), for: .disabled)
        button.bounds = CGRect(origin: .zero, size: CGSize(width: 40, height: 25))
        button.isEnabled = false
        return button
    } ()
    
    lazy var searchField: UITextField = {
        let field = UITextField(frame: .zero)
        field.borderStyle = .none
        let leftView = UIImageView(image: #imageLiteral(resourceName: "SearchGray"))
        leftView.contentMode = .center
        leftView.bounds = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        field.leftView = leftView
        field.leftViewMode = .always
        field.rightView = self.addButton
        field.rightViewMode = .whileEditing
        field.textColor = .white
        field.font = UIFont.systemFont(ofSize: 16)
        field.returnKeyType = .done
        field.attributedPlaceholder =
            NSMutableAttributedString(string: "输入标签内容", attributes: [.foregroundColor: UIColor(hex: 0x9B9B9B)])
        return field
    } ()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        let image = #imageLiteral(resourceName: "TopicCell")
            .resizableImage(
                withCapInsets: UIEdgeInsets(top: 22, left: 5, bottom: 23, right: 6),
                resizingMode: .stretch
        )
        let imageView = UIImageView(image: image)
        contentView.addSubview(imageView)
        imageView.fill(in: contentView, left: 10, right: 10, top: 1, bottom: 1)
        contentView.addSubview(searchField)
        searchField.fill(in: imageView, left: 10, right: 10, top: 5, bottom: 5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
