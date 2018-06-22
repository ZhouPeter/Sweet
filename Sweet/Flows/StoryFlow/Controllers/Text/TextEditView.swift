//
//  TextEditView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/22.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TextEditView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        spellCheckingType = .no
        autocorrectionType = .no
        textColor = .white
        textContainerInset = .zero
        font = UIFont.systemFont(ofSize: FontSize.max)
        enableShadow()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(select(_:)) || action == #selector(selectAll(_:)) {
            return true
        }
        return false
    }
}

struct FontSize {
    static let max: CGFloat = 180
    static let min: CGFloat = 20
}
