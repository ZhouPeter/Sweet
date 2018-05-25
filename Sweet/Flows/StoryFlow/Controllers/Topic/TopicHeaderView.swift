//
//  TopicHeaderView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TopicHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let image = #imageLiteral(resourceName: "TopicCell")
            .resizableImage(
                withCapInsets: UIEdgeInsets(top: 22, left: 5, bottom: 23, right: 6),
                resizingMode: .stretch
        )
        let backgroundImageView = UIImageView(image: image)
        addSubview(backgroundImageView)
        backgroundImageView.fill(in: self, left: 10, right: 10, top: 1, bottom: 1)
        
        let searchImageView = UIImageView(image: #imageLiteral(resourceName: "SearchGray"))
        addSubview(searchImageView)
        searchImageView.constrain(width: 20, height: 30)
        searchImageView.align(.left, to: self, inset: 10)
        
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .none
        textField.placeholder = "输入话题内容"
    }
}
