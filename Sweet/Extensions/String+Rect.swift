//
//  String+Rect.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/17.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension String {
    
    func boundingSize(font: UIFont, size: CGSize) -> CGSize {
        let text = self as NSString
        let attributes = [NSAttributedStringKey.font: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect: CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect.size
    }
    
}
