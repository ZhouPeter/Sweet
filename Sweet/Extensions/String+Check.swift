//
//  String+Check.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension String {
    
    func checkPhone() -> Bool {
        return count == 11
    }
    
    func checkTel() -> Bool {
        let regex = "^(0[0-9]{2,3}/-)?([2-9][0-9]{6,7})+(/-[0-9]{1,4})?$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
    func phoneMiddleHidden() -> String {
        guard self.checkPhone() else { return self }
        let phone = "\(self[...self.index(self.startIndex, offsetBy: 2)])" +
                    "****" +
                    "\(self[self.index(self.startIndex, offsetBy: 7)...])"
        return phone
    }
}
