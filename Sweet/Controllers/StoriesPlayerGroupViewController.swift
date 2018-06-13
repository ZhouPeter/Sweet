//
//  StoriesPlayerGroupViewController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Gemini
protocol StoriesPlayerGroupViewControllerDelegate: NSObjectProtocol {
    func readGroup(storyId: UInt64, fromCardId: String?, storyGroupIndex: Int)
}
class StoriesPlayerGroupViewController: BaseViewController {
    weak var delegate: StoriesPlayerGroupViewControllerDelegate?
    var user: User
    var currentIndex: Int {
        didSet {
            delegate?.readGroup(storyId: storiesGroup[currentIndex][0].storyId,
                                fromCardId: fromCardId,
                                storyGroupIndex: currentIndex)
        }
    }
    var storiesGroup: [[StoryCellViewModel]]
    var subCurrentIndex = 0
    var fromCardId: String?
    
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
        collectionView.isPagingEnabled = true
        collectionView.gemini.cubeAnimation().cubeDegree(90)
        return collectionView
    }()
    
    private var storiesPlayerControllers = [StoriesPlayerViewController]()
    
    init(user: User, storiesGroup: [[StoryCellViewModel]], currentIndex: Int, fromCardId: String? = nil) {
        self.user = user
        self.storiesGroup = storiesGroup
        self.currentIndex = currentIndex
        self.fromCardId = fromCardId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.fill(in: view)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setChildViewController()
        storiesPlayerControllers[currentIndex].initPlayer()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setChildViewController() {
        for index in 0 ..< storiesGroup.count {
            let stories = storiesGroup[index]
            let playerController = StoriesPlayerViewController(user: user)
            playerController.fromCardId = fromCardId
            playerController.delegate = self
            playerController.stories = stories
            if index == currentIndex {
                playerController.currentIndex = subCurrentIndex
            } else {
                playerController.currentIndex = 0
            }
            storiesPlayerControllers.append(playerController)
            add(childViewController: playerController, addView: false)
        }

        collectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .right, animated: false)
    }
    
    private func appendGroup(storyCellViewModels: [StoryCellViewModel]) {
        storiesGroup.append(storyCellViewModels)
        let playerController = StoriesPlayerViewController(user: user)
        playerController.fromCardId = fromCardId
        playerController.delegate = self
        playerController.stories = storyCellViewModels
        storiesPlayerControllers.append(playerController)
        add(childViewController: playerController, addView: false)
    }
    
    private func setOldPlayerControllerLoction() {
        let viewController = storiesPlayerControllers[currentIndex]
        if viewController.currentIndex == viewController.stories.count - 1 {
            viewController.currentIndex = 0
        } else {
            viewController.currentIndex += 1
        }
    }
    
    private func loadMoreStoriesGroup() {
        web.request(.storySortList, responseType: Response<StoriesGroupResponse>.self) { (result) in
            switch result {
            case let .success(response):
                response.list.forEach({
                    let storyCellViewModels = $0.map { StoryCellViewModel(model: $0) }
                    self.appendGroup(storyCellViewModels: storyCellViewModels)
                })
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension StoriesPlayerGroupViewController: StoriesPlayerViewControllerDelegate {
    func dismissController() {
        dismiss(animated: false, completion: nil)
    }
    
    func playToBack() {
        if currentIndex - 1 < 0 { return }
        collectionView.scrollToItem(at: IndexPath(item: currentIndex - 1, section: 0), at: .left, animated: true)
    }
    
    func playToNext() {
        if currentIndex + 1 > storiesGroup.count - 1 { return }
        collectionView.scrollToItem(at: IndexPath(item: currentIndex + 1, section: 0), at: .left, animated: true)

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
        cell.setPlaceholderContentView(view: storiesPlayerControllers[indexPath.row].view)
        return cell
    }
}

extension StoriesPlayerGroupViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.animateVisibleCells()
        let count = storiesGroup.count
        storiesPlayerControllers[currentIndex].pause()
        let index = Int(scrollView.contentOffset.x / UIScreen.mainWidth())
        if index < 0 || index >= count { return }
        if CGFloat(index) * UIScreen.mainWidth() == scrollView.contentOffset.x {
            if index == currentIndex {
                storiesPlayerControllers[currentIndex].play()
                return
            }
            storiesPlayerControllers[currentIndex].closePlayer()
            setOldPlayerControllerLoction()
            currentIndex = index
            storiesPlayerControllers[currentIndex].reloadPlayer()
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if currentIndex >= storiesGroup.count - 2 {
            loadMoreStoriesGroup()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if currentIndex >= storiesGroup.count - 2 {
            loadMoreStoriesGroup()
        }
    }
}
