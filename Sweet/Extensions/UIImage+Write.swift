//
//  UIImage+Write.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIImage {
    func writeToCache(withAlpha: Bool) -> URL? {
        let data: Data
        let suffix: String
        if withAlpha {
            guard let image = UIImagePNGRepresentation(self) else { return nil }
            data = image
            suffix = ".png"
        } else {
            guard let image = UIImageJPEGRepresentation(self, 0.8) else { return nil }
            data = image
            suffix = ".jpg"
        }
        do {
            let url = URL.photoCacheURL(withName: UUID().uuidString + suffix)
            try data.write(to: url)
            return url
        } catch {
            logger.error(error)
            return nil
        }
    }
}
