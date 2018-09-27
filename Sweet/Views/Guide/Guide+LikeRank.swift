//
//  Guide+LikeRank.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension Guide {
    class func showLikeRankHelpMessage() {
        let guide = Guide()
        let view = guide.rootView
        let mask = UIView()
        mask.backgroundColor = .black
        mask.alpha = 0.6
        view.addSubview(mask)
        mask.fill(in: view)
        let label = InsetLabel()
        label.contentInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let string = """
        当有人给你点赞，你的❤️就会+1
        """
        let size = string.boundingSize(font: UIFont.systemFont(ofSize: 18),
                                       size: CGSize(width: UIScreen.mainWidth() - 40 - 40,
                                                    height: CGFloat.greatestFiniteMagnitude))
        if size.height < 2 * UIFont.systemFont(ofSize: 18).lineHeight {
            label.attributedText = string.getAttributedString(lineSpacing: 0)
        } else {
            label.attributedText = string.getAttributedString(lineSpacing: 20)
        }
        label.font = UIFont.systemFont(ofSize: 18)
        label.backgroundColor = .white
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        view.addSubview(label)
        label.centerY(to: view)
        label.constrain(height: 80)
        label.align(.left, inset: 20)
        label.align(.right, inset: 20)
    }
}

