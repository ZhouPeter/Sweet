//
//  GIFImageMake.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/17.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MobileCoreServices

class GIFImageMake: NSObject {
   @objc class func makeSaveGIF(gifName: String, images: [UIImage]) -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let gifPath = documentsDirectory+"/\(gifName)"
        let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let destion = CGImageDestinationCreateWithURL(url!, kUTTypeGIF, images.count, nil)
        let cgimagePropertiesDic = [kCGImagePropertyGIFDelayTime as String: 0.1]//设置每帧之间播放时间
        let cgimagePropertiesDestDic = [kCGImagePropertyGIFDictionary as String: cgimagePropertiesDic]
        for cgimage in images {
            // 依次为gif图像对象添加每一帧元素
            CGImageDestinationAddImage(destion!, cgimage.cgImage!, cgimagePropertiesDestDic as CFDictionary?)
        }
        let gifPropertiesDic: NSMutableDictionary = NSMutableDictionary()
        gifPropertiesDic.setValue(kCGImagePropertyColorModelRGB, forKey: kCGImagePropertyColorModel as String)
        gifPropertiesDic.setValue(16, forKey:kCGImagePropertyDepth as String)// 设置图像的颜色深度
        gifPropertiesDic.setValue(3, forKey:kCGImagePropertyGIFLoopCount as String)// 设置Gif执行次数, 0则为无限执行
        gifPropertiesDic.setValue(NSNumber.init(booleanLiteral: true), forKey: kCGImagePropertyGIFHasGlobalColorMap as String)
        let gifDictionaryDestDic = [kCGImagePropertyGIFDictionary as String: gifPropertiesDic]
        CGImageDestinationSetProperties(destion!, gifDictionaryDestDic as CFDictionary?)//为gif图像设置属性
        CGImageDestinationFinalize(destion!)//最后释放 目标对象 destion
        return url as! URL
    }
}
