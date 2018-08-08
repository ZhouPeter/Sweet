//
//  FocusView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class FocusView: UIView {
    let focusRect: CGRect
    
    init(focusRect: CGRect) {
        self.focusRect = focusRect
        super.init(frame: .zero)
        backgroundColor = .clear
        alpha = 0.6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath(rect: rect)
        let hole = UIBezierPath(roundedRect: focusRect, cornerRadius: focusRect.height * 0.5)
        path.append(hole)
        path.usesEvenOddFillRule = true
        UIColor.black.setFill()
        path.fill()
    }
}

class FocusTagView: UIView {
    let focusPath: CGPath
    
    init(focusPath: CGPath) {
        self.focusPath = focusPath
        super.init(frame: .zero)
        backgroundColor = .clear
        alpha = 0.6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath(rect: rect)
        let hole = UIBezierPath(cgPath: focusPath)
        path.append(hole)
        path.usesEvenOddFillRule = true
        UIColor.black.setFill()
        path.fill()
    }
}
