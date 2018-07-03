//
//  RootViewController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/29.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Cover"))
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        imageView.fill(in: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
