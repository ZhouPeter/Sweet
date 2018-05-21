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
class CardsSubscriptionController: CardsBaseController, CardsSubscriptionView {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLoadCards()
    }
    
    private func startLoadCards() {
        web.request(.subscriptionCards, responseType: Response<CardListResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.cards.removeAll()
                self.cellConfigurators.removeAll()
                response.list.forEach({ (card) in
                    self.cards.append(card)
                    self.appendConfigurator(card: card)
                })
                self.collectionView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }

}
