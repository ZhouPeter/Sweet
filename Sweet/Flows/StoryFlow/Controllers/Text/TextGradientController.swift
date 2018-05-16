//
//  TextGradientController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/16.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TextGradientController: UIViewController {
    private let gradientView = GradientView()
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "输入文字内容..."
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(gradientView)
        gradientView.fill(in: view)
        view.addSubview(placeholderLabel)
        placeholderLabel.center(to: view)
        
        gradientView.colors = [UIColor(hex: 0x3023AE), UIColor(hex: 0xC86DD7)]
        gradientView.mode = .linearWithPoints(
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: view.bounds.width, y: view.bounds.height)
        )
    }
}
