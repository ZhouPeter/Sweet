//
//  TapGestureRecognizer.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

class TapGestureRecognizer: UITapGestureRecognizer {
    var path : CGPath?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        let loction = location(in: view)
        if let path = path, !path.contains(loction) {
            state = .failed
        }
    }
}
