//
//  BorderContentView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class BorderContentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        
        let bx1: CGFloat = 0, by1: CGFloat = 0, ex1: CGFloat = frame.width, ey1: CGFloat = 0
        let begin1 = CGPoint(x: bx1, y: by1)
        let end1 = CGPoint(x: ex1, y: ey1)
        let path1 = CGMutablePath()
        path1.move(to: begin1)
        path1.addLine(to: end1)
        
        let bx2: CGFloat = 0, by2: CGFloat = frame.height, ex2: CGFloat = frame.width, ey2: CGFloat = frame.height
        let begin2 = CGPoint(x: bx2, y: by2)
        let end2 = CGPoint(x: ex2, y: ey2)
        let path2 = CGMutablePath()
        path2.move(to: begin2)
        path2.addLine(to: end2)
        
        context!.addPath(path1)
        context!.addPath(path2)
        
        context!.setLineWidth(1)
        context!.setStrokeColor(UIColor.xpSeparatorGray().cgColor)
        context!.drawPath(using: .fillStroke)
    }
}
