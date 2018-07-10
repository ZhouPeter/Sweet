//
//  String+HTMlL.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation


extension String {
    func getHtmlAttributedString(font: UIFont, textColor: UIColor) -> NSAttributedString? {
        let addHeaderString = "<head><style>img{width:\(font.pointSize)px ;height: \(font.pointSize)px}</style></head>" + self
        let attributedText = try? NSMutableAttributedString(
            data: addHeaderString.data(using: String.Encoding.unicode)!,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        attributedText?.addAttributes([NSAttributedStringKey.font: font,
                                       NSAttributedStringKey.foregroundColor: textColor],
                                      range: NSRange(location: 0, length: attributedText!.length))
        return attributedText
    }
}
