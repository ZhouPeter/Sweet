//
//  UIViewController+ShareCard.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import JDStatusBarNotification
import SwiftyUserDefaults
extension UIViewController {
    func shareCard(card: CardResponse) {
        let text = card.makeShareText()
        let storyDraft = card.makeStoryDraft()
        let controller = ShareCardController(shareText: text, storyDraft: storyDraft)
        controller.sendCallback = { (text, userIds) in
            CardMessageManager.shard.sendMessage(card: card, text: text, userIds: userIds)
        }
        controller.shareCallback = { draft in
            guard let IDString = Defaults[.userID], let userID = UInt64(IDString) else { return }
            let task = StoryPublishTask(storage: Storage(userID: userID), draft: draft)
            task.finishBlock = { isSuccess in
                JDStatusBarNotification.show(withStatus: isSuccess ? "转发成功" : "转发失败", dismissAfter: 2)
            }
            TaskRunner.shared.run(task)
        }
        present(controller, animated: true, completion: nil)
        
    }
}
