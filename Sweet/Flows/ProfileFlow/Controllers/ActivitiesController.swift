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
    private var activityList = [PreferenceTextResponse]()
    private var viewModels = [PreferenceTextViewModel]() {
        didSet {
            cellNumber = viewModels.count
        }
    }
    
    private var groupCount = [Int]()
    private var page = 0
    private var loadFinish = false
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.mainWidth() - 6) / 3, height: (UIScreen.mainHeight() - 6) / 3)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.xpGray()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ActivityCollectionViewCell.self, forCellWithReuseIdentifier: "ActivityCollectionCell")
        collectionView.register(SweetCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        return collectionView
    }()
    private lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.placehoder = "可以带一句你想说的话"
        view.delegate = self
        return view
    }()
    private var activityId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.fill(in: view)
        loadRequest()
    }
    
    func loadRequest() {
        if viewModels.count > 0 { return }
        page = 0
        web.request(
            .preferenceTextList(page: 0, userId: user.userId,
                                contentId: setTop?.contentId,
                                preferenceId: setTop?.preferenceId),
            responseType: Response<PreferenceTextListResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.activityList = response.list
                    self.loadFinish = response.list.count < 10
                    self.viewModels = response.list.map {
                        var viewModel = PreferenceTextViewModel(model: $0)
                        viewModel.callBack = { activityId in
                            self.showInputView(activityId: viewModel.activityId)
                        }
                        return viewModel
                    }
                    for (index, viewModel) in self.viewModels.enumerated() {
                        if viewModel.isSame == false {
                            self.groupCount.append(index)
                            self.groupCount.append(self.viewModels.count - index)
                            break
                        }
                        if index == self.viewModels.count - 1 && viewModel.isSame {
                            self.groupCount.append(self.viewModels.count)
//                            self.groupCount.append(0)
                        }
                    }
                    self.collectionView.contentOffset = .zero
                    self.collectionView.reloadData()
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    
    func loadMoreRequest() {
        if loadFinish { return }
        page += 1
        web.request(
            .preferenceTextList(page: page, userId: user.userId,
                          contentId: setTop?.contentId, preferenceId: setTop?.preferenceId),
            responseType: Response<PreferenceTextListResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.activityList.append(contentsOf: response.list)
                    self.loadFinish = response.list.count < 10
                    self.viewModels.append(contentsOf: response.list.map {
                        var viewModel = PreferenceTextViewModel(model: $0)
                        viewModel.callBack = { activityId in
                            self.showInputView(activityId: viewModel.activityId)
                        }
                        return viewModel
                    })
                    self.collectionView.reloadData()
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    
    private func showInputView(activityId: String) {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(inputTextView)
        inputTextView.fill(in: window)
        inputTextView.layoutIfNeeded()
        inputTextView.startEditing(isStarted: true)
        self.activityId = activityId
    }
    
    private func showOriginalCard(viewModel: ActivityCardViewModel) {
        web.request(
            .reviewCard(cardID: viewModel.fromCardId),
            responseType: Response<CardGetResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    let card = response.card
                    if card.cardEnumType == .content, let video = card.video {
                        let videoURL =  URL(string: video)!
                        let asset = SweetPlayerManager.assetNoCache(for: videoURL)
                        let playerItem = AVPlayerItem(asset: asset)
                        let player = AVPlayer(playerItem: playerItem)
                        let controller = PlayController()
                        controller.avPlayer = player
                        controller.resource = SweetPlayerResource(url: videoURL)
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
                            let controller = ShareWebViewController(urlString: url.absoluteString, cardId: viewModel.fromCardId)
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                case let .failure(error):
                    logger.error(error)
                }
        }
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
        let toUserId = activityList[index].userId
        let cardID = activityList[index].cardId
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
                let viewModel = PreferenceTextViewModel(model: self.activityList[item])
                self.viewModels[item] = viewModel
                if item > self.groupCount[0] - 1 {
                    self.collectionView.reloadItems(at: [IndexPath(item: item - self.groupCount[0], section: 1)])
                } else {
                    self.collectionView.reloadItems(at: [IndexPath(item: item, section: 0)])
                }
            case let  .failure(error):
                logger.error(error)
            }
        }
    }
}
extension ActivitiesController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groupCount.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupCount[section]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ActivityCollectionCell",
            for: indexPath) as? ActivityCollectionViewCell else { fatalError() }
        let index = indexPath.section == 0 ? indexPath.row : indexPath.row + groupCount[0]
        cell.update(viewModel: viewModels[index])
        return cell
    }
    
}
extension ActivitiesController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.section == 0 ? indexPath.row : indexPath.row + groupCount[0]
        let viewModel = viewModels[index]
        if viewModel.isLike == false && viewModel.isHiddenLikeButton == false {
            showInputView(activityId: viewModel.activityId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModels.count - 1 && indexPath.section == groupCount.count - 1 {
            loadMoreRequest()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "headerView",
            for: indexPath) as? SweetCollectionHeaderView else { fatalError() }
        cell.update(title: "更多喜欢")
        return cell
    }
    
}

extension ActivitiesController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize(width: UIScreen.mainWidth(), height: 30)
        } else {
            return .zero
        }
    }
}

extension ActivitiesController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.acitvitiesScrollViewDidScroll(scrollView: scrollView)
    }
}
