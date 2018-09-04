//
//  StoryPublishTask.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class StoryPublishTask: AsynchronousOperation {
    private var draft: StoryDraft
    private let storage: Storage
    private let generator = StoryGenerator()
    private var filter: LookupFilter?
    var finishBlock: ((Bool) -> Void)?
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
        
        generate { [weak self] in
            guard let `self` = self else { return }
            var isSuccess = false
            self.publish(completion: { (result) in
                self.storage.write({ (realm) in
                    guard result == .success || result == .fileNotFound else { return }
                    if let data = realm.object(ofType: StoryDraftData.self, forPrimaryKey: self.draft.filename) {
                        realm.delete(data)
                        do {
                            let fileURL = self.draft.fileURL
                            try FileManager.default.removeItem(at: fileURL)
                            logger.debug("Delete draft file \(fileURL)")
                        } catch {
                            logger.error(error)
                        }
                        isSuccess = result == .success
                    }
                }) { (_) in
                    self.finishBlock?(isSuccess)
                    self.state = .finished
                }
            })
        }
    }
    
    private func generate(callback: @escaping () -> Void) {
        guard draft.generatedFilename == nil else {
            callback()
            return
        }
        let targetFilter: LookupFilter
        if let name = draft.filterFilename, let image = UIImage(named: name) {
            targetFilter = LookupFilter(lookupImage: image)
        } else {
            targetFilter = LookupFilter(lookupImage: UIImage(named: "1")!)
        }
        self.filter = targetFilter
        let handleOutput: ((URL?) -> Void) = { [weak self] url in
            guard let url = url, let `self` = self else { return }
            logger.debug(self.draft.fileURL, url)
            self.draft.generatedFilename = url.lastPathComponent
            self.storage.write({ (realm) in
                realm.add(StoryDraftData.data(with: self.draft), update: true)
            }, callback: { (_) in callback() })
        }
        if draft.storyType.isVideoFile {
            var overlay: UIImage?
            if let name = draft.overlayFilename {
                overlay = UIImage(contentsOfFile: URL.photoCacheURL(withName: name).path)
            }
            DispatchQueue.main.async {
                self.generator.generateVideo(
                    with: URL.videoCacheURL(withName: self.draft.filename),
                    filter: targetFilter,
                    overlay: overlay,
                    callback: handleOutput
                )
            }
        } else {
            var overlay: UIImage?
            if let name = draft.overlayFilename {
                overlay = UIImage(contentsOfFile: URL.photoCacheURL(withName: name).path)
            }
            generator.generateImage(
                with: URL.photoCacheURL(withName: draft.filename),
                filter: targetFilter,
                overlay: overlay,
                callback: handleOutput
            )
        }
    }
    
    private func publish(completion: @escaping (Result) -> Void) {
        let uploadType: UploadType
        switch draft.storyType {
        case .text, .image, .share:
            uploadType = .storyImage
        default:
            uploadType = .storyVideo
        }
        let fileURL = draft.fileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            completion(.fileNotFound)
            return
        }
        Upload.uploadFileToQiniu(localURL: draft.fileURL, type: uploadType) { [weak self] (token, error) in
            guard let token = token, let `self` = self else {
                logger.debug("upload failed \(error?.localizedDescription ?? "")")
                completion(.uploadError)
                return
            }
            logger.debug(token.urlString)
            web.request(
                .publishStory(
                    url: token.urlString,
                    type: self.draft.storyType,
                    topic: self.draft.topic,
                    pokeCenter: self.draft.pokeCenter,
                    touchPoints: self.draft.touchPoints,
                    comment: self.draft.comment,
                    desc: self.draft.desc,
                    rawUrl: self.draft.url,
                    fromCardId: self.draft.fromCardId
                ),
                completion: { (result) in
                    logger.debug(result)
                    if case .success = result {
                        completion(.success)
                    } else {
                        completion(.publishError)
                    }
            })
        }
    }
    
    enum Result {
        case uploadError
        case publishError
        case fileNotFound
        case success
    }
}
