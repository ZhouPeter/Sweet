//
//  GradientSwitchView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/16.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class GradientSwitchView: UIView {
    private let backgroundView = GradientView()
    private let foregroundView = GradientView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        foregroundView.frame = bounds
    }
    
    // MARK: - Private
    
    private func setup() {
        addSubview(backgroundView)
        addSubview(foregroundView)
    }
    
    func changeColors(_ colors: [UIColor]?, animated: Bool = false) {
        changeGradients(changeBackground: {
            backgroundView.colors = colors
        }, changeForeground: {
            self.foregroundView.colors = colors
        }, animated: animated)
    }
    
    func changeMode(_ mode: GradientView.Mode, animated: Bool = false) {
        changeGradients(changeBackground: {
            backgroundView.mode = mode
        }, changeForeground: {
            self.foregroundView.mode = mode
        }, animated: animated)
    }
    
    private func changeGradients(
        changeBackground: () -> Void,
        changeForeground: @escaping () -> Void,
        animated: Bool = false) {
        if animated {
            changeBackground()
            UIView.animate(withDuration: 0.45, delay: 0, options: [.curveEaseOut], animations: {
                self.backgroundView.alpha = 1
                self.foregroundView.alpha = 0
            }, completion: { _ in
                changeForeground()
                self.foregroundView.alpha = 1
                self.backgroundView.alpha = 0
            })
        } else {
            changeBackground()
            changeForeground()
            foregroundView.alpha = 1
            backgroundView.alpha = 0
        }
    }
}
