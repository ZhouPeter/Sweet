//
//  StoryPublisher.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import APESuperHUD

class StoryPublisher {
    func publish(
        with url: URL,
        storyType: StoryType,
        topic: String? = nil,
        pokeCenter: CGPoint? = nil,
        completion: @escaping (Bool) -> Void) {
        let uploadType: UploadType
        switch storyType {
        case .text, .image:
            uploadType = .storyImage
        default:
            uploadType = .storyVideo
        }
        APESuperHUD.show(style: HUDStyle.loadingIndicator(type: .standard), message: "发布中")
        Upload.uploadFileToQiniu(localURL: url, type: uploadType) { (token, error) in
            guard let token = token else {
                logger.debug("upload failed \(error?.localizedDescription ?? "")")
                APESuperHUD.show(style: HUDStyle.textOnly, message: "发布失败")
                completion(false)
                return
            }
            logger.debug(token.urlString)
            web.request(
                .publishStory(
                    url: token.urlString,
                    type: storyType,
                    topic: topic,
                    pokeCenter: pokeCenter
                ),
                completion: { (result) in
                    logger.debug(result)
                    if case .success = result {
                        completion(true)
                        
                        APESuperHUD.show(style: HUDStyle.textOnly, message: "发布成功")
                    } else {
                        APESuperHUD.show(style: HUDStyle.textOnly, message: "发布失败")
                        completion(false)
                    }
            })
        }
    }
}