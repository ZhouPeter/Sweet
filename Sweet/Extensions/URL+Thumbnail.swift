//
//  URL+Thumbnail.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension URL {
    func imageView2(size: CGSize) -> URL? {
        let scale = UIScreen.main.scale
        if absoluteString.contains("?imageView2") || lastPathComponent.lowercased().hasSuffix(".gif") {
            return self
        } else {
            return URL(string: absoluteString +
                            "?imageView2/5/w/\(Int(size.width * scale))/h/\(Int(size.height * scale))")
        }
    }
    
    func videoThumbnail(size: CGSize = .zero) -> URL? {
        let scale = UIScreen.main.scale
        let url = URL(string: absoluteString +
            "?vframe/jpg/offset/0.0/w/\(Int(size.width * scale))/h/\(Int(size.height * scale))" )
        return url
    }
}
