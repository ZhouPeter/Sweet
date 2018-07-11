//
//  StorysController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol StoriesView: BaseView {
    
}

class StoriesCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var selfIndex: Int = 0
    private let width = UIScreen.mainWidth() / 3
    private let height = UIScreen.mainHeight() / 3
    var attrsList = [UICollectionViewLayoutAttributes]()
    override func prepare() {
        super.prepare()
        creatAttrs()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsList
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attrs.frame.size.width = width
        attrs.frame.size.height = height
        if indexPath.row < selfIndex {
            attrs.frame.origin.x = width * CGFloat(indexPath.row % 3)
            attrs.frame.origin.y = height * CGFloat(indexPath.row / 3)
        } else {
            attrs.frame.origin.x = width * CGFloat((indexPath.row + 1) % 3)
            attrs.frame.origin.y = height * CGFloat((indexPath.row + 1) / 3)
        }
        return attrs
    }
    
    private func creatAttrs() {
        attrsList.removeAll()
        guard let count = collectionView?.numberOfItems(inSection: 0) else { return }
        if selfIndex < count {
            let label = UILabel()
            label.text = "之后部分\n仅自己可见"
            label.textAlignment = .center
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .black
            label.frame = CGRect(x: width * CGFloat(selfIndex % 3),
                                 y: height * CGFloat(selfIndex / 3),
                                 width: width,
                                 height: height)
            collectionView?.addSubview(label)
        }
        for index in 0 ..< count {
            let indexPath = IndexPath(item: index, section: 0)
            if let attrs = layoutAttributesForItem(at: indexPath) {
                attrsList.append(attrs)
            }
        }
    }
}

protocol StoriesControllerDelegate: NSObjectProtocol {
    func storiesScrollViewDidScroll(scrollView: UIScrollView)
}
class StoriesController: UIViewController, PageChildrenProtocol {
    var showStoriesPlayerView: (
    (
        User,
        [StoryCellViewModel],
        Int,
        StoriesPlayerGroupViewControllerDelegate?) -> Void
    )?
    
    var user: User
    weak var delegate: StoriesControllerDelegate?
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var storyViewModels = [StoryCellViewModel]()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.mainWidth() - 12) / 3,
                                 height: (UIScreen.mainHeight() - 12) / 3)
        layout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.xpGray()
        collectionView.register(StoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: "storyCell")
        return collectionView

    }()
    private var page = 0
    private var loadFinish = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        view.addSubview(collectionView)
        collectionView.fill(in: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    func loadRequest() {
        page = 0
        web.request(
            .storyList(page: 0, userId: user.userId),
            responseType: Response<StoryListResponse>.self) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case let .success(response):
                    self.loadFinish = response.list.count < 20
                    self.storyViewModels = response.list.map({return StoryCellViewModel(model: $0)})
                    self.reviewViewModels()
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
            .storyList(page: page, userId: user.userId),
            responseType: Response<StoryListResponse>.self) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case let .success(response):
                    self.loadFinish = response.list.count < 20
                    self.storyViewModels.append(contentsOf: response.list.map({ return StoryCellViewModel(model: $0)}))
                    self.reviewViewModels()
                    self.collectionView.reloadData()
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    
    private func reviewViewModels() {
        for index in 0..<storyViewModels.count {
            if storyViewModels[index].created/1000 + 72 * 3600 < Int(Date().timeIntervalSince1970) {
                storyViewModels[index].visualText = "仅自己可见"
                break
            }
        }
    }
}

extension StoriesController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return storyViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "storyCell",
            for: indexPath) as? StoryCollectionViewCell else { fatalError() }
        cell.update(viewModel: storyViewModels[indexPath.row])
        return cell
    }
    
}

extension StoriesController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.storiesScrollViewDidScroll(scrollView: scrollView)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showStoriesPlayerView?(user, storyViewModels, indexPath.item, self)
    
    }
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.row == storyViewModels.count - 1 {
            loadMoreRequest()
        }
    }
}

extension StoriesController: StoriesPlayerGroupViewControllerDelegate {
    func delStory(storyId: UInt64) {
        guard let index = storyViewModels.index(where: { $0.storyId == storyId }) else { return }
        storyViewModels.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
}
