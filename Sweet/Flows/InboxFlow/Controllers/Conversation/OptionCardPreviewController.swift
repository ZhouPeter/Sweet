//
//  OptionCardPreviewController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import STPopup

final class OptionCardPreviewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let size = CGSize(width: 356, height: 535)
        let scale = UIScreen.mainHeight() / 667
        contentSizeInPopup = CGSize(width: size.width * scale, height: size.height * scale)
        popupController?.navigationBarHidden = true
    }
}
