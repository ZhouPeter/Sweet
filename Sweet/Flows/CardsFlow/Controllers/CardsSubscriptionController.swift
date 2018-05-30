//
//  CardsSubscriptionController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
protocol CardsSubscriptionView: BaseView {
    
}
class CardsSubscriptionController: CardsBaseController, CardsSubscriptionView {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func didReceiveMemoryWarning() {
        logger.error("SubMemoryWarning")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.cards.count == 0 {
            let subCardsLastID = Defaults[.subCardsLastID]
            startLoadCards(
            cardRequest: .sub(cardId: subCardsLastID,
                              direction: Direction.recover.rawValue)) { [weak self] (success) in
                if success { self?.collectionView.reloadData() }
            }
        }
    }
    
//    override func startLoadCards(cardId: String?, direction: Int?, callback: ((_ success: Bool) -> Void)? = nil) {
//        if isFetchLoadCards { return }
//        isFetchLoadCards = true
//        web.request(
//        .subscriptionCards(cardId: cardId, direction: direction),
//        responseType: Response<CardListResponse>.self) { [weak self] (result) in
//            guard let `self` = self else { return }
//            self.isFetchLoadCards = false
//            switch result {
//            case let .success(response):
//                response.list.forEach({ (card) in
//                    self.cards.append(card)
//                    self.appendConfigurator(card: card)
//                })
//                callback?(true)
//            case let .failure(error):
//                logger.error(error)
//            }
//        }
//    }

}
