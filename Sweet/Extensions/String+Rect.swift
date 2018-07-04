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
    
    func getTextAttributed(lineSpacing: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    
    func boundingSize(font: UIFont, size: CGSize, lineSpacing: CGFloat) -> CGSize{
        let text = self as NSString
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle,
                          NSAttributedStringKey.font: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect: CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect.size
    }
}
