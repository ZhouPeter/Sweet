//
//  URL+Thumbnail.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Alamofire

struct ImageInfo: Codable {
    let format: String
    let width: Int
    let height: Int
}
extension URL {
    func imageView2(size: CGSize) -> URL? {
        let scale = UIScreen.main.scale
        if absoluteString.contains("?imageView2") || lastPathComponent.lowercased().hasSuffix(".gif") {
            return self
        } else {
            return URL(string: absoluteString +
                    "?imageView2/1/w/\(Int(size.width * scale))/h/\(Int(size.height * scale))")
        }
    }
    
    func videoThumbnail(size: CGSize = .zero) -> URL? {
        let scale = UIScreen.main.scale
        let url = URL(string: absoluteString +
            "?vframe/jpg/offset/0.0/w/\(Int(size.width * scale))/h/\(Int(size.height * scale))")
        return url
    }
    
    func imageInfoSize(completion: ((ImageInfo?, Bool) -> Void)?) {
        guard let url = URL(string: self.absoluteString + "?imageInfo") else { return }
        Alamofire.request(url).responseJSON { (response) in
            response.result.ifFailure {
                completion?(nil, false)
            }
            response.result.ifSuccess {
                if let JSON = response.result.value, let dictionay = JSON as? [String: Any] {
                    do {
                        let info = try JSONDecoder().decode(ImageInfo.self, from: dictionay)
                        completion?(info, true)
                    } catch {
                        completion?(nil, false)
                    }
                } else {
                    completion?(nil, false)
                }
            }
        }
    }
}
