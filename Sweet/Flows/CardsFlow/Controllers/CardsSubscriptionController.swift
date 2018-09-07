//
//  CardsSubscriptionController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
protocol CardsSubscriptionView: CardsBaseView {

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
    }
    
    func loadCards() {
        if self.cards.count == 0 {
            let subCardsLastID = Defaults[.subCardsLastID]
            startLoadCards(
            cardRequest: .sub(cardId: subCardsLastID, direction: Direction.recover)) {
                [weak self] (success, _) in
                if success {
                    self?.mainView.collectionView.reloadData()
                    self?.mainView.collectionView.performBatchUpdates(nil, completion: { (_) in
                        self?.changeCurrentCell()
                    })
                }
            }
        } else {
            changeCurrentCell()
        }
    }
    
}
