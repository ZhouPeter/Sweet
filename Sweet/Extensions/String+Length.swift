//
//  String+Length.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension String {

    func substringLans(kMaxLength: Int, position: UITextPosition?) -> String? {
        var toBeString = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        toBeString = toBeString.replacingOccurrences(of: "\r", with: "")
        toBeString = toBeString.replacingOccurrences(of: "\n", with: "")
        let lang = UIApplication.shared.textInputMode?.primaryLanguage
        let length = toBeString.lengthOfBytes()
        if let lang = lang, lang == "zh-Hans" {
            if position == nil {
                if length > kMaxLength {
                    return middleEachStringToSub(kMaxLength: kMaxLength, length: length, text: toBeString)
                }
            }
        } else {
            if length > kMaxLength {
                return middleEachStringToSub(kMaxLength: kMaxLength, length: length, text: toBeString)
            }
         }
        return nil
    }
    
    private func lengthOfBytes() -> Int {
        var length = 0
        for char in self {
            // 判断是否中文，是中文+2 ，不是+1
            length += "\(char)".lengthOfBytes(using: String.Encoding.utf8) >= 3 ? 2 : 1
        }
        return length
    }
    
    private func middleEachStringToSub(kMaxLength: Int, length: Int, text: String) -> String {
        var newText = text
        for index in kMaxLength/2 ... kMaxLength {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: index)
            newText = String(text[startIndex ..< endIndex])
            if newText.lengthOfBytes() == kMaxLength {
                break
            } else if newText.lengthOfBytes() > kMaxLength {
                let startIndex = text.startIndex
                let endIndex = text.index(startIndex, offsetBy: index - 1)
                newText = String(text[startIndex ..< endIndex])

            }
        }
        return newText
    }
    
}
