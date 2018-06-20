//
//  UIViewController+Toast.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import PKHUD

open class PKHUDCustomTextView: PKHUDWideBaseView {
    static let defaultWideBaseViewFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 104))
    public init(text: String?) {
        super.init(frame: PKHUDCustomTextView.defaultWideBaseViewFrame)
        commonInit(text)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit("")
    }
    
    func commonInit(_ text: String?) {
        titleLabel.text = text
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(titleLabel)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 10.0
        titleLabel.frame = bounds.insetBy(dx: padding, dy: padding)
    }
    
    open let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 3
        return label
    }()
}

extension UIViewController {
    func toast(message: String, duration: Double = 2, completion: (() -> Void)? = nil) {
        PKHUD.toast(message: message, duration: duration, completion: completion)
    }
}

extension PKHUD {
    class func toast(message: String, duration: Double = 2, completion: (() -> Void)? = nil) {
        PKHUD.sharedHUD.contentView = PKHUDCustomTextView(text: message)
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: duration) { (_) in
            completion?()
        }
    }
}
