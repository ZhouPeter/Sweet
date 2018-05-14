//
//  CardsSubscriptionController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol CardsSubscriptionView: BaseView {
    
}
class CardsSubscriptionController: BaseViewController, CardsSubscriptionView {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }

}
