//
//  URL+Thumbnail.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension URL {
    func middleCutting(size: CGSize) -> URL? {
        let scale = UIScreen.main.scale
        if absoluteString.contains("?imageView2") {
            return self
        } else {
            return URL(string: absoluteString +
                            "?imageView2/1/w/\(Int(size.width * scale))/h/\(Int(size.height * scale))")
        }
    }
    
    func videoThumbnail(size: CGSize) -> URL? {
        let scale = UIScreen.main.scale
        return URL(string: absoluteString +
                            "?vframe/jpg/offset/0.0/w/\(Int(size.width * scale))/h/\(Int(size.height * scale))" )
    }
}