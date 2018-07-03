//
//  StoryPublishTask.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class StoryPublishTask: AsynchronousOperation {
    let draft: StoryDraft
    let storage: Storage
    
    init(storage: Storage, draft: StoryDraft) {
        self.draft = draft
        self.storage = storage
        storage.write({ (realm) in
            realm.add(StoryDraftData.data(with: draft), update: true)
        }, callbackQueue: nil, callback: nil)
    }
    
    override func main() {
        guard !isCancelled else {
            state = .finished
            return
        }
        state = .executing
        logger.debug(draft.filename)
        publish(
        with: draft.fileURL,
        storyType: draft.storyType,
        topic: draft.topic,
        pokeCenter: draft.pokeCenter,
        contentRect: draft.contentRect) { [weak self] (result) in
            guard let `self` = self else { return }
            logger.debug(result)
            self.storage.write({ (realm) in
                guard result else { return }
                if let data = realm.object(ofType: StoryDraftData.self, forPrimaryKey: self.draft.filename) {
                    realm.delete(data)
                }
            }) { (_) in
                self.state = .finished
            }
        }
    }
    
    private func publish(
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
        Upload.uploadFileToQiniu(localURL: url, type: uploadType) { (token, error) in
            guard let token = token else {
                logger.debug("upload failed \(error?.localizedDescription ?? "")")
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
                    } else {
                        completion(false)
                    }
            })
        }
    }
}
