//
//  StoriesPlayerGroupViewController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Gemini
import Hero
import Kingfisher
import SwiftyUserDefaults

protocol StoriesPlayerGroupViewControllerDelegate: NSObjectProtocol {
    func delStory(storyId: UInt64)
    func updateStory(story: StoryCellViewModel, postion: (Int, Int))
    func willDisAppper(index: Int)
}

extension StoriesPlayerGroupViewControllerDelegate {
    func delStory(storyId: UInt64) {}
    func updateStory(story: StoryCellViewModel, postion: (Int, Int)) {}
    func willDisAppper(index: Int) {}
}

class StoriesPlayerGroupViewController: BaseViewController, StoriesGroupView {
    
    var runProfileFlow: ((UInt64) -> Void)?
    
    var runStoryFlow: ((String) -> Void)?

    var onFinish: (() -> Void)?
    
    var currentPlayController: StoriesPlayerViewController? {
        if let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) {
            return storiesPlayerControllerMap[cell]
        }
        return nil
    }
    
    func pause() {
        currentPlayController?.pause()
//        for cell in collectionView.visibleCells {
//            storiesPlayerControllerMap[cell]?.pause()
//        }
    }
    
    func play() {
        currentPlayController?.play()

//        for cell in collectionView.visibleCells {
//            storiesPlayerControllerMap[cell]?.play()
//        }
    }
    
    weak var delegate: StoriesPlayerGroupViewControllerDelegate?
    var user: User
    var currentIndex: Int
    var storiesGroup: [[StoryCellViewModel]]
    var currentStart = 0
    var fromCardId: String?
    var fromMessageId: String?
    static private var loctionMap = [String: Int]()
    private var isLoading = false
    private lazy var collectionView: GeminiCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.mainWidth(), height: UIScreen.mainHeight())
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        let collectionView = GeminiCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(StoryPlayCollectionViewCell.self, forCellWithReuseIdentifier: "placeholderCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        collectionView.isPagingEnabled = true
        collectionView.gemini.cubeAnimation().cubeDegree(90).shadowEffect(.fadeIn)
        return collectionView
    }()
    
    private var storiesPlayerControllerMap = [UICollectionViewCell: StoriesPlayerViewController]()
    private var isHasMoreStories = true
    init(user: User,
         storiesGroup: [[StoryCellViewModel]],
         currentIndex: Int,
         currentStart: Int = 0,
         fromCardId: String? = nil,
         fromMessageId: String? = nil) {
        self.user = user
        self.storiesGroup = storiesGroup
        self.currentIndex = currentIndex
        self.currentStart = currentStart
        self.fromCardId = fromCardId
        self.fromMessageId = fromMessageId
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        logger.debug()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let index = storiesGroup[0..<currentIndex].reduce(0) { $0 + $1.count } + currentPlayController!.currentIndex
        delegate?.willDisAppper(index: index)
        for cell in collectionView.visibleCells {
            savePlayerControllerLoction(cell: cell)
        }
        if fromCardId == nil {
            var newLocionMap = [String: Int]()
            StoriesPlayerGroupViewController.loctionMap.forEach { (key, value) in
                if key.count > 10 {
                    newLocionMap[key] = value
                }
            }
            StoriesPlayerGroupViewController.loctionMap = newLocionMap
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var pan = CustomPanGestureRecognizer(orientation: .down, target: self, action: #selector(didPan(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        collectionView.addGestureRecognizer(pan)
        collectionView.hero.isEnabled = true
        collectionView.hero.id = "\(storiesGroup[currentIndex][0].userId)" + (fromCardId ?? "") + (fromMessageId ?? "")
        collectionView.isScrollEnabled = storiesGroup.count > 1
        view.addSubview(collectionView)
        collectionView.fill(in: view)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.layoutIfNeeded()
        collectionView.setContentOffset(CGPoint(x: UIScreen.mainWidth() * CGFloat(currentIndex),
                                                y: 0),
                                        animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Defaults[.isStoryPlayGuideShown] == false {
            Guide.showStoryPlayTip()
            Defaults[.isStoryPlayGuideShown] = true
        }
    }
    
    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let progress = translation.y / view.bounds.height
        switch gesture.state {
        case .began:
            onFinish?()
        case .changed:
            Hero.shared.update(progress)
            let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
            Hero.shared.apply(modifiers: [.position(currentPos)], to: collectionView)
        default:
            if progress + gesture.velocity(in: nil).y / view.bounds.height > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func getChildViewController(cell: UICollectionViewCell) -> StoriesPlayerViewController {
        if let controller = storiesPlayerControllerMap[cell] {
            return controller
        }
        let playerController = StoriesPlayerViewController(user: user)
        playerController.delegate = self
        playerController.fromCardId = fromCardId
        playerController.runStoryFlow = runStoryFlow
        playerController.runProfileFlow = runProfileFlow
        add(childViewController: playerController, addView: false)
        storiesPlayerControllerMap[cell] = playerController
        return playerController
    }
    
    private func appendGroup(storyCellViewModels: [StoryCellViewModel]) {
        storiesGroup.append(storyCellViewModels)
        collectionView.insertItems(at: [IndexPath(row: storiesGroup.count - 1, section: 0)])
    }
    
    private func savePlayerControllerLoction(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let keyValue = (fromCardId ?? "") + "#\(storiesGroup[indexPath.row][0].userId)" + "#\(indexPath.row)"
            StoriesPlayerGroupViewController.loctionMap[keyValue] = storiesPlayerControllerMap[cell]?.currentIndex
        }
    }
    
    private func readPlayerControllerLoction(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let keyValue = (fromCardId ?? "") + "#\(storiesGroup[indexPath.row][0].userId)" + "#\(indexPath.row)"
            storiesPlayerControllerMap[cell]?.currentIndex = StoriesPlayerGroupViewController.loctionMap[keyValue] ?? 0
        }
    }

    private func loadMoreStoriesGroup() {
        if storiesGroup[0][0].userId == user.userId {
            isHasMoreStories = false
            return
        }
        if isLoading { return }
        web.request(.storySortList, responseType: Response<StoriesGroupResponse>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            self.isLoading = false
            switch result {
            case let .success(response):
                response.list.forEach({
                    let storyCellViewModels = $0.map { StoryCellViewModel(model: $0) }
                    self.appendGroup(storyCellViewModels: storyCellViewModels)
                })
                if response.list.count == 0 && self.currentIndex == self.storiesGroup.count - 1 {
                    self.isHasMoreStories = false
                }
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}
// MARK: - StoriesPlayerViewControllerDelegate
extension StoriesPlayerGroupViewController: StoriesPlayerViewControllerDelegate {
    func updateStory(story: StoryCellViewModel, position: (Int, Int)) {
        storiesGroup[position.0][position.1] = story
        if position.0 < 4 { delegate?.updateStory(story: story, postion: position) }
    }
    func delStory(storyId: UInt64) {
        delegate?.delStory(storyId: storyId)
    }
    func dismissController() {
        onFinish?()
    }
    
    func playToBack() {
        if currentIndex - 1 < 0 { return }
        collectionView.scrollToItem(at: IndexPath(item: currentIndex - 1, section: 0), at: .left, animated: true)
    }
    
    func playToNext() {
        if currentIndex + 1 > storiesGroup.count - 1 {
            onFinish?()
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: currentIndex + 1, section: 0), at: .left, animated: true)
    }
}

extension StoriesPlayerGroupViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urlsGroup = indexPaths.compactMap { (indexPath) -> [URL]? in
            let stories = storiesGroup[indexPath.row]
            let urls = stories.compactMap { (story) -> URL? in
                if story.type == .video || story.type == .poke, let videoURL = story.videoURL {
                    return videoURL.videoThumbnail()
                } else if let imageURL = story.imageURL {
                    return imageURL.imageView2(size: view.bounds.size)
                } else {
                    return nil
                }
            }
            return urls
        }
        urlsGroup.forEach({
            logger.debug($0)
            ImagePrefetcher(urls: $0).start()
        })
    }
}

extension StoriesPlayerGroupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storiesGroup.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "placeholderCell",
            for: indexPath) as? StoryPlayCollectionViewCell else {fatalError()}
        let playerController = getChildViewController(cell: cell)
        playerController.stories = storiesGroup[indexPath.row]
        playerController.groupIndex = indexPath.row
        let keyValue = (fromCardId ?? "") + "#\(storiesGroup[currentIndex][0].userId)" + "#\(indexPath.row)"
        playerController.currentIndex = StoriesPlayerGroupViewController.loctionMap[keyValue] ?? 0
        if currentIndex == indexPath.row {
            let keyValue = (fromCardId ?? "") + "#\(storiesGroup[currentIndex][0].userId)" + "#\(indexPath.row)"
            playerController.currentIndex = StoriesPlayerGroupViewController.loctionMap[keyValue] ?? currentStart
        }
        cell.setPlaceholderContentView(view: playerController.view)
        playerController.update()
        if currentIndex == indexPath.row { playerController.initPlayer() }
        pan.require(toFail: playerController.storiesScrollView.scrollViewTap)
        return cell
    }
}

extension StoriesPlayerGroupViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.animateVisibleCells()
        currentPlayController?.pause()
        let count = storiesGroup.count
        let index = Int(scrollView.contentOffset.x / UIScreen.mainWidth())
        if index < 0 || index >= count { return }
        if CGFloat(index) * UIScreen.mainWidth() == scrollView.contentOffset.x {
            if index == currentIndex {
                currentPlayController?.play()
                loadMoreStoriesGroup()
                return
            }
            if currentIndex >= storiesGroup.count - 2 {
                loadMoreStoriesGroup()
            }
            currentIndex = index
            for cell in collectionView.visibleCells {
                if let indexPath = collectionView.indexPath(for: cell), indexPath.row != currentIndex {
                    savePlayerControllerLoction(cell: cell)
                    storiesPlayerControllerMap[cell]?.closePlayer()
                }
                if let indexPath = collectionView.indexPath(for: cell), indexPath.row == currentIndex {
                    readPlayerControllerLoction(cell: cell)
                    storiesPlayerControllerMap[cell]?.reloadPlayer()
                }
            }
        }
    }
}
