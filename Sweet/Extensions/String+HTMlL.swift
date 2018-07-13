//
//  String+HTMlL.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation


extension String {
    func getHtmlAttributedString(font: UIFont, textColor: UIColor, lineSpacing: CGFloat) -> NSAttributedString? {
        let addHeaderString = "<head><style>img{width:\(font.pointSize)px ;height: \(font.pointSize)px}</style></head>" + self
        let attributedText = try? NSMutableAttributedString(
            data: addHeaderString.data(using: String.Encoding.unicode)!,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        attributedText?.addAttributes([ NSAttributedStringKey.paragraphStyle:paragraphStyle, 
                                        NSAttributedStringKey.font: font,
                                        NSAttributedStringKey.foregroundColor: textColor],
                                      range: NSRange(location: 0, length: attributedText!.length))
        return attributedText
    }
    
    static func getShareText(content: String?, url: String?) -> String? {
        let text: String?
        if let content = content, let url = url {
            if let string = content.htmlStringReplaceTag() {
                let substring = string.prefix(50)
                text = substring + url + "\n" + "\n"
                    + "讲真APP，你的同学都在玩：" + "\n"
                    + "[机智]http://t.cn/RrXTSg5"
            } else {
                text = nil
            }
        } else {
            text = nil
        }
        return text
    }
    
    func htmlStringReplaceTag() -> String? {
        do {
            let imgRegular = try NSRegularExpression(pattern: "<img[^>]*>", options: [])
            let spritImgRegular = try NSRegularExpression(pattern: "</img[^>]*>", options: [])
            let brRegular = try NSRegularExpression(pattern: "<br[^>]*>", options: [])
            let spritBrRegular = try NSRegularExpression(pattern: "</br[^>]*>", options: [])
            var string = self
            string = imgRegular.stringByReplacingMatches(
                in: string,
                options: .reportProgress,
                range: NSRange(location: 0, length: string.utf16.count),
                withTemplate: "")
            string = spritImgRegular.stringByReplacingMatches(
                in: string,
                options: .reportProgress,
                range: NSRange(location: 0, length: string.utf16.count),
                withTemplate: "")
            string = brRegular.stringByReplacingMatches(
                in: string,
                options: .reportProgress,
                range: NSRange(location: 0, length: string.utf16.count),
                withTemplate: "\n")
            string = spritBrRegular.stringByReplacingMatches(
                in: string,
                options: .reportProgress,
                range: NSRange(location: 0, length: string.utf16.count),
                withTemplate: "")
            return string
        } catch {
            return nil
        }
    }
}
