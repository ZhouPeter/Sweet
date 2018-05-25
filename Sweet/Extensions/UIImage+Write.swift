//
//  UIImage+Write.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIImage {
    func writeToCache() -> URL? {
        guard let data = UIImageJPEGRepresentation(self, 0.8) else { return nil }
        do {
            let url = URL.photoCacheURL(withName: UUID().uuidString + ".jpg")
            try data.write(to: url)
            return url
        } catch {
            logger.error(error)
            return nil
        }
    }
}
