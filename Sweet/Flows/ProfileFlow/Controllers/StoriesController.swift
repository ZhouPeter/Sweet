//
//  StorysController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
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
class StoriesController: UIViewController, PageChildrenProtocol {

    var userId: UInt64?
    private var storyViewModels = [StoryCellViewModel]() {
        didSet {
            layout.selfIndex = storyViewModels.count
            for index in 0..<storyViewModels.count {
                let maxShowTime = storyViewModels[index].created/1000 + 72 * 3600
                if maxShowTime < Int(Date().timeIntervalSince1970) {
                    layout.selfIndex = index
                    break
                }
            }
        }
    }
    
    private var layout = StoriesCollectionViewFlowLayout()

    private lazy var collectionView: UICollectionView = {
        layout.itemSize = CGSize(width: UIScreen.mainWidth() / 3,
                                 height: UIScreen.mainHeight() / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.xpGray()
        collectionView.register(StoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: "storyCell")
        return collectionView

    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        view.addSubview(collectionView)
        collectionView.fill(in: view)
        loadRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadRequest() {
        guard let userId = userId else { return }
        web.request(.storyList(page: 0, userId: userId),
                    responseType: Response<StoryListResponse>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                self.storyViewModels.removeAll()
                response.list.forEach({ (story) in
                    let viewModel = StoryCellViewModel(model: story)
                    self.storyViewModels.append(viewModel)
                })
                for index in 1...10 {
                    let url = URL(string: "http://cdn02.miaobo.me/2sfemale-001-\(index).mp4")!
                    let viewModel = StoryCellViewModel(videoURL: url)
                    self.storyViewModels.append(viewModel)
                }
                self.collectionView.reloadData()
            case let .failure(error):
                logger.error(error)
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
    
}