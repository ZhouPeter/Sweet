//
//  FeedsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import JDStatusBarNotification
import SwiftyUserDefaults
protocol ActivitiesControllerDelegate: NSObjectProtocol {
    func acitvitiesScrollViewDidScroll(scrollView: UIScrollView)
}
class ActivitiesController: UIViewController, PageChildrenProtocol {
    var showProfile: ((UInt64, SetTop?, (() -> Void)?) -> Void)?
    var cellNumber: Int = 0
    var user: User
    var avatar: String
    let setTop: SetTop?
    weak var delegate: ActivitiesControllerDelegate?
    init(user: User, avatar: String, setTop: SetTop? = nil) {
        self.user = user
        self.avatar = avatar
        self.setTop = setTop
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var activityList = [ActivityResponse]()
    private var viewModels = [ActivityCardViewModel]() {
        didSet {
            cellNumber = viewModels.count
        }
    }
    private var page = 0
    private var loadFinish = false
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(AcitivityCardTableViewCell.self, forCellReuseIdentifier: "ActivityCell")
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
        loadRequest()
    }
    
    func loadRequest() {
        if viewModels.count > 0 { return }
        page = 0
        web.request(
            .activityList(page: 0, userId: user.userId,
                          contentId: setTop?.contentId, preferenceId: setTop?.preferenceId),
            responseType: Response<ActivityListResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.activityList = response.list
                    self.loadFinish = response.list.count < 10
                    self.viewModels = response.list.map {
                        var viewModel = ActivityCardViewModel(model: $0, userAvatarURL: URL(string: self.avatar))
                        viewModel.callBack = { activityId in
                            self.showInputView(activityId: viewModel.activityId)
                        }
                        return viewModel
                    }
                    self.tableView.contentOffset = .zero
                    self.tableView.reloadData()
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    
    func loadMoreRequest() {
        if loadFinish { return }
        page += 1
        web.request(
            .activityList(page: page, userId: user.userId,
                          contentId: setTop?.contentId, preferenceId: setTop?.preferenceId),
            responseType: Response<ActivityListResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.activityList.append(contentsOf: response.list)
                    self.loadFinish = response.list.count < 10
                    self.viewModels.append(contentsOf: response.list.map {
                        var viewModel = ActivityCardViewModel(model: $0, userAvatarURL: URL(string: self.avatar))
                        viewModel.callBack = { activityId in
                            self.showInputView(activityId: viewModel.activityId)
                        }
                        return viewModel
                    })
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
    }
}

// MARK: - InputTextViewDelegate
extension ActivitiesController: InputTextViewDelegate {
    func inputTextViewDidPressSendMessage(text: String) {
        inputTextView.clear()
        inputTextView.startEditing(isStarted: false)
        inputTextView.removeFromSuperview()
        sendActivityMessages(text: text)
    }
    
    func removeInputTextView() {
        inputTextView.clear()
        inputTextView.startEditing(isStarted: false)
        inputTextView.removeFromSuperview()
    }
}

extension ActivitiesController {
    func sendActivityMessages(text: String) {
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
                    CardMessageManager.shard.sendMessage(card: resultCard, text: text, userIds: [toUserId], extra: activityId)
                    self.requestActivityLike(activityId: activityId, comment: text)
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    private func requestActivityLike(activityId: String, comment: String) {
        web.request(.activityCardLike(cardId: nil, activityId: activityId, comment: comment)) { (result) in
            switch result {
            case .success:
                guard let item = self.activityList.index(where: { $0.activityId == activityId }) else { return }
                self.activityList[item].like = true
                let viewModel = ActivityCardViewModel(model: self.activityList[item],
                                                      userAvatarURL: URL(string: self.avatar))
                self.viewModels[item] = viewModel
                self.tableView.reloadRows(at: [IndexPath(row: item, section: 0)], with: .automatic)
            case let  .failure(error):
                logger.error(error)
            }
        }
    }
}
extension ActivitiesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ActivityCell", for: indexPath) as? AcitivityCardTableViewCell else {fatalError()}
        cell.update(viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
  
}

extension ActivitiesController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.acitvitiesScrollViewDidScroll(scrollView: scrollView)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (cardCellHeight - 50) / 4
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModels.count - 1 {
            loadMoreRequest()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.row]
        web.request(
            .reviewCard(cardID: viewModel.fromCardId),
            responseType: Response<CardGetResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    let card = response.card
                    if card.cardEnumType == .content, let video = card.video {
                        let videoURL =  URL(string: video)!
                        VideoCardPlayerManager.shared.play(with: videoURL)
                        let controller = PlayController()
                        controller.avPlayer = VideoCardPlayerManager.shared.player
                        controller.resource = SweetPlayerResource(url: videoURL)
                        VideoCardPlayerManager.shared.player = nil
                        self.present(controller, animated: true, completion: nil)
                    } else if card.cardEnumType == .choice {
                        var text = ""
                        if let content = card.content, let textString = try? content.htmlStringReplaceTag() {
                            text = textString
                        }
                        let result = card.result == nil ? -1 : card.result!.index!
                        let content = OptionCardContent(
                            identifier: card.cardId,
                            cardType: InstantMessage.CardType.preference,
                            text: text,
                            leftImageURLString: card.imageList![0],
                            rightImageURLString: card.imageList![1],
                            result: OptionCardContent.Result(rawValue: result)!
                        )
                        let preview = OptionCardPreviewController(content: content, user: self.user)
                        preview.showProfile = self.showProfile
                        let popup = PopupController(rootViewController: preview)
                        popup.present(in: self)
                    } else {
                        if let url = viewModel.url {
                            let controller = ShareWebViewController(urlString: url, cardId: viewModel.fromCardId)
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
}
