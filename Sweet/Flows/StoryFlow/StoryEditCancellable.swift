//
//  StoryEditCancellable.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol StoryEditCancellable: class {
    var presentable: UIViewController { get }
    
    func cancelEditing(_ callback: @escaping () -> Void)
}

extension StoryEditCancellable {
    func cancelEditing(_ callback: @escaping () -> Void) {
        let controller = UIAlertController(title: "确认删除？", message: nil, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (_) in
            callback()
        }))
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        presentable.present(controller, animated: true, completion: nil)
    }
}
