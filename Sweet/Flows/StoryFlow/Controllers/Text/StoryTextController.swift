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
    
    private lazy var textView: UITextView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = .clear
        view.font = UIFont.systemFont(ofSize: 60)
        return view
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(textView)
        textView.align(.left, to: view, inset: 20)
        textView.align(.right, to: view, inset: 20)
        textView.align(.bottom, to: view, inset: 20)
        textView.align(.top, to: view, inset: 40)
    }
}
