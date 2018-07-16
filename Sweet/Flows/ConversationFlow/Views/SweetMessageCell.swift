//
//  SweetMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/16.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import MessageKit

class SweetMessageCell: MessageContentCell {
    var accessory = Accessory.none
    lazy var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    lazy var resendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Like"), for: .normal)
        return button
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        accessoryView.addSubview(indicator)
        indicator.isHidden = true
        indicator.fill(in: accessoryView)
        accessoryView.addSubview(resendButton)
        resendButton.fill(in: accessoryView)
        resendButton.isHidden = true
    }
    
    func updateAccessory(_ accessory: Accessory) {
        switch accessory {
        case .none:
            indicator.isHidden = true
            resendButton.isHidden = true
        case .loading:
            indicator.isHidden = false
            indicator.startAnimating()
            resendButton.isHidden = true
        case .resend:
            indicator.isHidden = true
            resendButton.isHidden = false
        }
    }
    
    enum Accessory {
        case none
        case loading
        case resend
    }
}
