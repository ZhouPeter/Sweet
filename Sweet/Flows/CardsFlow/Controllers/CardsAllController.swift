//
//  CardsController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
protocol CardsAllView: CardsBaseView {
    
}

class CardsAllController: CardsBaseController, CardsAllView {
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    override func didReceiveMemoryWarning() {
        logger.error("AllMemoryWarning")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.cards.count == 0 {
            let allCardsLastID = Defaults[.allCardsLastID]
            startLoadCards(
                cardRequest: .all(cardId: allCardsLastID,
                                  direction: Direction.recover)) { [weak self] (success, _) in
                if success {
                    self?.collectionView.reloadData()
                    self?.collectionView.performBatchUpdates(nil, completion: { (_) in
                        self?.changeCurrentCell()
                    })
                }
            }
        }
    }
    
}
