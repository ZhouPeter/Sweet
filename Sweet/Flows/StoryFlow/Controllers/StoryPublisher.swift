//
//  StoryPublisher.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import PKHUD

class StoryPublisher {
    func publish(
        with url: URL,
        storyType: StoryType,
        topic: String? = nil,
        pokeCenter: CGPoint? = nil,
        contentRect: CGRect? = nil,
        completion: @escaping (Bool) -> Void) {
        let uploadType: UploadType
        switch storyType {
        case .text, .image:
            uploadType = .storyImage
        default:
            uploadType = .storyVideo
        }
        HUD.show(.systemActivity)
        Upload.uploadFileToQiniu(localURL: url, type: uploadType) { (token, error) in
            guard let token = token else {
                logger.debug("upload failed \(error?.localizedDescription ?? "")")
                HUD.flash(.error, delay: 1)
                completion(false)
                return
            }
            logger.debug(token.urlString)
            web.request(
                .publishStory(
                    url: token.urlString,
                    type: storyType,
                    topic: topic,
                    pokeCenter: pokeCenter,
                    contentRect: contentRect
                ),
                completion: { (result) in
                    logger.debug(result)
                    if case .success = result {
                        completion(true)
                        
                        HUD.flash(.success, delay: 1)
                    } else {
                        HUD.flash(.error, delay: 1)
                        completion(false)
                    }
            })
        }
    }
}
