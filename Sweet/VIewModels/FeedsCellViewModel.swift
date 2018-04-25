//
//  FeedsCellViewModel.swift
//  XPro
//
//  Created by Mario Z. on 2018/3/30.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

struct FeedsCellViewModel {
    let cellHeight: CGFloat = 100
    let avatarURL: URL?
    let title: String
    let subtitle: String
    let content: String
    var bottomLabelFont = UIFont.systemFont(ofSize: 12)
    var isSelected: Bool = false
    var actionImage: UIImage = #imageLiteral(resourceName: "HeartRed")
    var actionImageSelected: UIImage = #imageLiteral(resourceName: "HeartRed")
    var doAction: (() -> Void)?
    
    init(avatarURL: URL?, title: String, subtitle: String = "", content: String) {
        self.avatarURL = avatarURL
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }
}
