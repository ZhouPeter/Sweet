//
//  EstimatesController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class EvaluationController: UIViewController, PageChildrenProtocol {
    var user: User
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var evaluationList = [EvaluationResponse]()
    private var viewModels = [EvaluationViewModel]()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EvaluationTableViewCell.self, forCellReuseIdentifier: "EvaluationCell")
        return tableView
    }()
    private lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "说点有意思的"
        view.delegate = self
        return view
    }()
    
    private var evaluationId: UInt64?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.fill(in: view)
        
    }
    
    func loadRequest() {
        web.request(
            .evaluationList(page: 0, userId: user.userId),
            responseType: Response<EvaluationListResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.evaluationList = response.list
                    response.list.forEach({
                        var viewModel = EvaluationViewModel(model: $0)
                        viewModel.isHiddenLikeImage = UInt64(Defaults[.userID]!)! == self.user.userId
                        viewModel.callback = {
                            self.showInputView(evaluationId: viewModel.evaluationId)
                        }
                        self.viewModels.append(viewModel)
                    })
                    self.tableView.reloadData()
                case let .failure(error):
                    logger.error(error)
                }
            
        }
    }

}

extension EvaluationController {
    private func showInputView(evaluationId: UInt64) {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(inputTextView)
        inputTextView.fill(in: window)
        inputTextView.startEditing(isStarted: true)
        self.evaluationId = evaluationId
    }
}
// MARK: - InputTextViewDelegate
extension EvaluationController: InputTextViewDelegate {
    func inputTextViewDidPressSendMessage(text: String) {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
        sendEvaluationMessages(text: text)
    }
    
    func removeInputTextView() {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
    }
}
extension EvaluationController {
    func sendEvaluationMessages(text: String) {
        let from = UInt64(Defaults[.userID]!)!
        guard let evaluationId = evaluationId else { return }
        guard let index = evaluationList.index(where: { $0.evaluationId == evaluationId }) else {fatalError()}
        let toUserId = user.userId
        let cardID = evaluationList[index].fromCardId
        web.request(
            WebAPI.getCard(cardID: cardID),
            responseType: Response<CardGetResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    let resultCard = response.card
                    if let content = MessageContentHelper.getContentCardContent(resultCard: resultCard) {
                        if resultCard.type == .evaluation, let content = content as? OptionCardContent {
                            Messenger.shared.sendEvaluationCard(content, from: from, to: toUserId)
                        }
                    } else {
                        return
                    }
                    Messenger.shared.sendLike(from: from, to: toUserId, extra: String(evaluationId))
                    if text != "" {
                        Messenger.shared.sendText(text, from: from, to: toUserId, extra: String(evaluationId))
                    }
                    self.requestEvaluationLike(evaluationId: evaluationId, comment: text)
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    private func requestEvaluationLike(evaluationId: UInt64, comment: String) {
        web.request(.likeEvaluation(evaluationId: evaluationId, comment: comment)) { (result) in
            switch result {
            case .success:
                guard let item = self.evaluationList.index(where: { $0.evaluationId == evaluationId }) else { return }
                self.evaluationList[item].like = true
                let viewModel = EvaluationViewModel(model: self.evaluationList[item])
                self.viewModels[item] = viewModel
                self.tableView.reloadRows(at: [IndexPath(row: item, section: 0)], with: .automatic)
                self.toast(message: "❤️ 评价成功")
            case let  .failure(error):
                logger.error(error)
            }
        }
    }
}

extension EvaluationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "EvaluationCell", for: indexPath)as? EvaluationTableViewCell else { fatalError() }
        cell.update(viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
}

extension EvaluationController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
