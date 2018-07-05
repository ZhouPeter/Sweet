//
//  UIButton+Topic.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIButton {
    convenience init(topic: String) {
        self.init(type: .custom)
        let image = #imageLiteral(resourceName: "TopicButton")
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 17), resizingMode: .stretch)
        setBackgroundImage(image, for: .normal)
        updateTopic("添加标签")
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func updateTopic(_ topic: String, withHashTag: Bool = true) {
        setAttributedTitle(NSMutableAttributedString(topic: topic, fontSize: 20, withHashTag: withHashTag), for: .normal)
    }
}

extension NSMutableAttributedString {
    convenience init(
        topic: String,
        fontSize: CGFloat,
        hashColor: UIColor = UIColor(hex: 0xF8E71C),
        textColor: UIColor = UIColor.white,
        withHashTag: Bool = true) {
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        self.init(string: "")
        if withHashTag {
            append(NSAttributedString(string: "# ", attributes: [.font: font, .foregroundColor: hashColor]))
        }
        append(NSAttributedString(string: topic, attributes: [.font: font, .foregroundColor: textColor]))
    }
}
