//
//  EvaluationViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct EvaluationViewModel {
    let evaluationId: UInt64
    let imageURL: URL
    let title: String
    let likeCountString: String
    var isHiddenLikeImage: Bool = true
    var likeButtonImage: UIImage?
    var callback: (() -> Void)?
    init(model: EvaluationResponse) {
        imageURL = URL(string: model.image)!
        title = model.text
        likeCountString = "x\(model.num)"
        likeButtonImage = model.like ? #imageLiteral(resourceName: "Like") : #imageLiteral(resourceName: "Unlike")
        evaluationId = model.evaluationId
    }
}
