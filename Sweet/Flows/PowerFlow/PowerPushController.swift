//
//  PowerPushController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/24.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class PowerPushController: BaseViewController, PowerPushView {
    var onFinish: (() -> Void)?
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "讲真"
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("允许发送通知", for: .normal)
        button.backgroundColor = UIColor.xpBlue()
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self,
                         action: #selector(openUserNotificationService(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "请允许"
        navigationItem.hidesBackButton = true
        setupUI()
        
    }
    
    @objc private func openUserNotificationService(_ sender: UIButton) {
        let appDelegate  = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.setUserNotificationCenter(completion: {
            DispatchQueue.main.async {
                 logger.debug("推送授权完毕")  
                 self.onFinish?()
            }
        })
    }

}

// MARK: - Privates
extension PowerPushController {
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.center(to: view, offsetY: -100)
        view.addSubview(doneButton)
        doneButton.constrain(height: 50)
        doneButton.align(.left, to: view, inset: 28)
        doneButton.align(.right, to: view, inset: 28)
        doneButton.pin(to: titleLabel, edge: .bottom, spacing: -28)
        doneButton.setViewRounded()
    }
}
