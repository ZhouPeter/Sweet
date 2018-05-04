//
//  StoryTextController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class StoryTextController: BaseViewController, StoryTextView {
    var onFinished: ((StoryText) -> Void)?
    
    private lazy var editController = StoryTextEditController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        addChildViewController(editController)
        editController.didMove(toParentViewController: self)
        view.addSubview(editController.view)
        editController.view.fill(in: view)
    }
}
