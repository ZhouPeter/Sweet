//
//  TaskRunner.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

final class TaskRunner {
    static let shared = TaskRunner()
    private let queue: OperationQueue
    
    private init() {
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: .UIApplicationDidEnterBackground,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
    }
    
    func run(_ operation: Operation) {
        queue.addOperation(operation)
    }
    
    @objc private func didEnterBackground() {
        queue.isSuspended = true
    }
    
    @objc private func willEnterForeground() {
        queue.isSuspended = false
    }
}

extension TaskRunner {
    func runUnfinishedStoryTasks(in storage: Storage) {
        var drafts = [StoryDraft]()
        storage.read({ (realm) in
            drafts.append(contentsOf: realm.objects(StoryDraftData.self).flatMap(StoryDraft.init(data:)))
        }) {
            logger.debug(drafts)
            drafts.forEach({ (draft) in
                self.run(StoryPublishTask(storage: storage, draft: draft))
            })
        }
    }
}

