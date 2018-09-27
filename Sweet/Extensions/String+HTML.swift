//
//  String+HTML.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension String {
    func getHtmlAttributedString(font: UIFont, textColor: UIColor, lineSpacing: CGFloat) -> NSAttributedString? {
        let addHeaderString = "<head><style>img{width:\(font.pointSize)px ;height: \(font.pointSize)px}</style></head>" + self
        guard let stringData = addHeaderString.data(using: String.Encoding.unicode) else { return nil }
        let attributes = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        guard let string =
            try? NSMutableAttributedString(data: stringData, options:attributes, documentAttributes: nil)
            else { return nil }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        string.addAttributes([.paragraphStyle:paragraphStyle, .font: font, .foregroundColor: textColor],
                             range: NSRange(location: 0, length: string.length))
        return string
    }
    
    func getAttributedString(lineSpacing: CGFloat, textAlignment: NSTextAlignment = .left) -> NSAttributedString {
        let string = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = textAlignment
        string.addAttributes([.paragraphStyle: paragraphStyle ], range: NSRange(location: 0, length: string.length))
        return string
    }
    
    static func getShareText(content: String?, url: String?) -> String? {
        let text: String?
        if let content = content, let url = url {
            if let string = try? content.htmlStringReplaceTag() {
                let substring = string.prefix(50)
                text = substring + url + "\n" + "\n"
                    + "讲真APP，你的同学都在玩：" + "\n"
                    + "[机智]https://mx.miaobo.me/dl"
            } else {
                text = nil
            }
        } else {
            text = nil
        }
        return text
    }
    
    func htmlStringReplaceTag() throws -> String {
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
    }
    
    func removedURLLinks() throws ->  String {
        let regx = try NSRegularExpression(
            pattern: "https?://(www.)?[-a-zA-Z0-9@:%._+~#=]{2,256}.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_+.~#?&//=]*)",
            options: []
        )
        var string = self
        return regx.stringByReplacingMatches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count),
            withTemplate: "[链接]")
    }
}
