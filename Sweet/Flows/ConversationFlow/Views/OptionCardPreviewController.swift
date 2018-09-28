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
    var showProfile: ((UInt64, SetTop?, (() -> Void)?) -> Void)?
    private let content: OptionCardContent
    private var contentCell: BaseCardCollectionViewCell?
    private var optionCell: ChoiceCardCollectionViewCell?
    private var cardResponse: CardResponse?
    private var user: User
    init(content: OptionCardContent, user: User) {
        self.content = content
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let size = CGSize(width: 356, height: 535)
//        let scale = UIScreen.mainHeight() / 667
        let scale = UIScreen.mainWidth() / 375
        contentSizeInPopup = CGSize(width: size.width * scale, height: size.height * scale)
        popupController?.navigationBarHidden = true
        let cardID = content.identifier
        let api: WebAPI = content.cardType == .preference ? .reviewCard(cardID: cardID) : .getCard(cardID: cardID)
        web.request(api, responseType: Response<CardGetResponse>.self) { [weak self] (result) in
            switch result {
            case .failure(let error):
                logger.error(error)
            case .success(let response):
                self?.handle(with: response.card)
            }
        }
    }
    
    private func handle(with card: CardResponse) {
        let rect = CGRect(origin: .zero, size: self.contentSizeInPopup).insetBy(dx: -10, dy: -10)
        if self.content.cardType == .evaluation {
            let cell = EvaluationCardCollectionViewCell(frame: rect)
            cell.updateWith(EvaluationCardViewModel(model: card))
            contentCell = cell
            view.addSubview(cell)
        } else if self.content.cardType == .preference {
            logger.debug(card)
            let cell = ChoiceCardCollectionViewCell(frame: rect)
            cell.updateWith(ChoiceCardViewModel(model: card))
            contentCell = cell
            optionCell = cell
            cardResponse = card
            cell.delegate = self
            view.addSubview(cell)
        }
        contentCell?.contentView.backgroundColor = .clear
        contentCell?.customContent.isShadowEnabled = false
        contentCell?.customContent.backgroundColor = .white
        contentCell?.menuButton.isHidden = true
    }
}

extension OptionCardPreviewController: ChoiceCardCollectionViewCellDelegate {
    
    func selectChoiceCard(cardId: String, selectedIndex: Int) {
        web.request(
            .choiceCard(cardId: cardId, index: selectedIndex),
            responseType: Response<SelectResult>.self
        ) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                guard var card = self.cardResponse else { return }
                card.result = response
                self.optionCell?.updateWith(ChoiceCardViewModel(model: card))
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    func showProfile(buddyID: UInt64, setTop: SetTop?) {
        showProfile?(buddyID, setTop, nil)
    }
}
