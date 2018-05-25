//
//  ChoiceCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ChoiceCardViewModel {
    let titleString: String
    let contentString: String
    let imageURL: [URL]
    var selectedIndex: Int?
    var percent: Double?
    var avatarURLs: [URL]?
    let cardId: String
    init(model: CardResponse) {
        self.cardId = model.cardId
        self.titleString = model.name!
        self.contentString = model.content!
        self.imageURL = model.imageList!.map({ (url) -> URL in
            return URL(string: url)!
        })
        if let result = model.result {
            self.selectedIndex = result.index
            self.percent = result.percent
            var urls = [URL]()
            result.contactUserList.forEach { (user) in
                let url = URL(string: user.avatar)!
                urls.append(url)
            }
            self.avatarURLs = urls
        } else {
            self.selectedIndex = 1
            self.percent = 12
            var urls = [URL]()
            urls.append(URL(string: "https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png")!)
            urls.append(URL(string: "https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png")!)
            urls.append(URL(string: "https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png")!)
            self.avatarURLs = urls
        }
    }
    
}
