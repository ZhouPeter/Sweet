//
//  FeedsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class ActivitiesController: UIViewController, PageChildrenProtocol {

    var userId: UInt64
    init(userId: UInt64) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var activityList = [ActivityResponse]()
    private var viewModels = [ActivityViewModel]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "ActivityCell")
        return tableView
    }()
    private lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "说点有意思的"
        view.delegate = self
        return view
    }()
    private var activityId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.fill(in: view)
    }
    
    func loadRequest() {
        web.request(
          .activityList(page: 0, userId: userId),
          responseType: Response<ActivityListResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.activityList = response.list
                self.viewModels = response.list.map {
                    var viewModel = ActivityViewModel(model: $0)
                    viewModel.callBack = { activityId in
                        self.showInputView(activityId: viewModel.activityId)
                    }
                    return viewModel
                }
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func showInputView(activityId: String) {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(inputTextView)
        inputTextView.fill(in: window)
        inputTextView.startEditing(isStarted: true)
        self.activityId = activityId
//        self.activityCardId = cardId
    }
}

// MARK: - InputTextViewDelegate
extension ActivitiesController: InputTextViewDelegate {
    func inputTextViewDidPressSendMessage(text: String) {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
        sendActivityMessages(text: text)
    }
    
    func removeInputTextView() {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
    }
}
extension ActivitiesController {
    func sendActivityMessages(text: String) {
        let from = UInt64(Defaults[.userID]!)!
        guard let activityId = activityId else { return }
        guard let index = activityList.index(where: { $0.activityId == activityId }) else {fatalError()}
        let toUserId = activityList[index].actor
        let cardID = activityList[index].fromCardId
        web.request(
            WebAPI.getCard(cardID: cardID),
            responseType: Response<CardGetResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    let resultCard = response.card
                    if let content = self.getContentCardContent(resultCard: resultCard) {
                        if resultCard.type == .content, let content = content as? ContentCardContent {
                            Messenger.shared.sendContentCard(content, from: from, to: toUserId)
                        } else if resultCard.type == .choice, let content = content as? OptionCardContent {
                            Messenger.shared.sendPreferenceCard(content, from: from, to: toUserId)
                        }
                    } else {
                        return
                    }
                    Messenger.shared.sendLike(from: from, to: toUserId, extra: activityId)
                    if text != "" { Messenger.shared.sendText(text, from: from, to: toUserId, extra: activityId) }
                    self.requestActivityLike(activityId: activityId, comment: text)
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    private func getContentCardContent(resultCard: CardResponse) -> MessageContent? {
        if resultCard.type == .content {
            let url: String
            if let videoUrl = resultCard.video {
                url = videoUrl + "?vsample/jpg/offset/0.0/w/375/h/667"
            } else {
                url = resultCard.contentImageList![0].url
            }
            let content = ContentCardContent(identifier: resultCard.cardId,
                                             cardType: InstantMessage.CardType.content,
                                             text: resultCard.content!,
                                             imageURLString: url,
                                             url: resultCard.url!)
            return content
        } else if resultCard.type == .choice {
            let result = resultCard.result == nil ? -1 : resultCard.result!.index!
            let content = OptionCardContent(identifier: resultCard.cardId,
                                            cardType: InstantMessage.CardType.preference,
                                            text: resultCard.content!,
                                            leftImageURLString: resultCard.imageList![0],
                                            rightImageURLString: resultCard.imageList![1],
                                            result: OptionCardContent.Result(rawValue: result)!)
            return content
        }
        return nil
    }
    
    private func requestActivityLike(activityId: String, comment: String) {
        web.request(.activityCardLike(cardId: nil, activityId: activityId, comment: comment)) { (result) in
            switch result {
            case .success:
                guard let item = self.activityList.index(where: { $0.activityId == activityId }) else { return }
                self.activityList[item].like = true
                let viewModel = ActivityViewModel(model: self.activityList[item])
                self.viewModels[item] = viewModel
                self.tableView.reloadRows(at: [IndexPath(row: item, section: 0)], with: .automatic)
                self.toast(message: "❤️ 评价成功")
            case let  .failure(error):
                logger.error(error)
            }
        }
    }
}
extension ActivitiesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ActivityCell", for: indexPath) as? ActivityTableViewCell else {fatalError()}
        cell.update(viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
}

extension ActivitiesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (cardCellHeight - 50) / 4
    }
}
