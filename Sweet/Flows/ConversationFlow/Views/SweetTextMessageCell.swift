//
//  SweetTextMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import MessageKit

final class SweetTextMessageCell: TextMessageCell {
    private var gradientView = GradientView()
    
    override func layoutMessageContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
        super.layoutMessageContainerView(with: attributes)
        gradientView.frame = messageContainerView.bounds
        gradientView.mode =
            .linearWithPoints(start: .zero, end: CGPoint(x: gradientView.bounds.maxX, y: gradientView.bounds.maxY))
    }
    
    func configureGradientColors(_ colors: [UIColor]) {
        gradientView.colors = colors
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.insertSubview(gradientView, at: 0)
    }
}
