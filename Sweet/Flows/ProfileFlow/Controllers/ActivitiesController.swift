//
//  FeedsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ActivitiesController: UIViewController, PageChildrenProtocol {

    var userId: UInt64
    init(userId: UInt64) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var activities = [ActivityResponse]()
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
                self.activities = response.list
                self.viewModels = response.list.map {
                    var viewModel = ActivityViewModel(model: $0)
                    viewModel.callBack = { activityItemId in
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
//        self.activityItemId = activityItemId
//        self.activityCardId = cardId
    }
}

// MARK: - InputTextViewDelegate
extension ActivitiesController: InputTextViewDelegate {
    func inputTextViewDidPressSendMessage(text: String) {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
//        let from = UInt64(Defaults[.userID]!)!
//        let toUserId = 1
//        if text != "" { Messenger.shared.sendText(text, from: from, to: toUserId, extra: itemId) }
//        Messenger.shared.sendLike(from: from, to: toUserId, extra: itemId)
//        web.request(.activityCardLike(cardId: cardId, activityItemId: itemId, comment: text)) { (result) in
//            switch result {
//            case .success:
//                guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
//                guard let item = self.cards[index].activityList!.index(
//                    where: { $0.activityItemId == itemId }) else { return }
//                self.cards[index].activityList![item].like = true
//                let viewModel = ActivitiesCardViewModel(model: self.cards[index])
//                let configurator = CellConfigurator<ActivitiesCardCollectionViewCell>(viewModel: viewModel)
//                self.cellConfigurators[index] = configurator
//                if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)),
//                    let acCell = cell as? ActivitiesCardCollectionViewCell {
//                    acCell.updateItem(item: item, like: true)
//                }
//                self.toast(message: "❤️ 评价成功")
//            case let  .failure(error):
//                logger.error(error)
//            }
//        }
    }
    
    func removeInputTextView() {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
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
        return activities.count
    }
}

extension ActivitiesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (cardCellHeight - 50) / 4
    }
}
