//
//  NSAttributeString+Size.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func getAttributedStringSize(width: CGFloat) -> CGSize {
        let size = self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil).size
        return size
    }
}
