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

protocol StoriesPlayerGroupViewControllerDelegate: NSObjectProtocol {
    func readGroup(storyId: UInt64, fromCardId: String?, storyGroupIndex: Int)
}
class StoriesPlayerGroupViewController: BaseViewController, StoriesGroupView {
    var runProfileFlow: ((User, UInt64) -> Void)?
    
    var runStoryFlow: ((String) -> Void)?

    var onFinish: (() -> Void)?
    
    func pause() {
        for cell in collectionView.visibleCells {
            storiesPlayerControllerMap[cell]?.pause()
        }
    }
    
    func play() {
        for cell in collectionView.visibleCells {
            storiesPlayerControllerMap[cell]?.play()
        }
    }
    
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
    private var loctionMap = [IndexPath: Int]()
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
        collectionView.isPagingEnabled = true
        collectionView.gemini.cubeAnimation().cubeDegree(90).shadowEffect(.fadeIn)
        return collectionView
    }()
    
    private var storiesPlayerControllerMap = [UICollectionViewCell: StoriesPlayerViewController]()
    
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
    
    private lazy var pan = PanGestureRecognizer(direction: .vertical, target: self, action: #selector(didPan(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        hero.isEnabled = true
        collectionView.addGestureRecognizer(pan)
        collectionView.hero.isEnabled = true
        collectionView.hero.id = "\(storiesGroup[currentIndex][0].userId)"

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
        delegate?.readGroup(storyId: storiesGroup[currentIndex][0].storyId,
                            fromCardId: fromCardId,
                            storyGroupIndex: currentIndex)
    }
    
    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let progress = translation.y / view.bounds.height
        switch gesture.state {
        case .began:
            logger.debug()
            dismiss(animated: true, completion: nil)
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
            loctionMap[indexPath] = storiesPlayerControllerMap[cell]?.currentIndex
        }
    }
    
    private func readPlayerControllerLoction(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            storiesPlayerControllerMap[cell]?.currentIndex = loctionMap[indexPath] ?? 0
        }
    }

    private func loadMoreStoriesGroup() {
        if isLoading { return }
        web.request(.storySortList, responseType: Response<StoriesGroupResponse>.self) { (result) in
            self.isLoading = false
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
        onFinish?()
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
        let playerController = getChildViewController(cell: cell)
        playerController.stories = storiesGroup[indexPath.row]
        playerController.currentIndex = loctionMap[indexPath] ?? 0
        cell.setPlaceholderContentView(view: playerController.view)
        playerController.update()
        if currentIndex == indexPath.row {
            playerController.currentIndex = subCurrentIndex
            playerController.initPlayer()
        }
        pan.require(toFail: playerController.storiesScrollView.scrollViewTap)
        return cell
    }
}

extension StoriesPlayerGroupViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.animateVisibleCells()
        for cell in collectionView.visibleCells {
            storiesPlayerControllerMap[cell]?.pause()
        }
        let count = storiesGroup.count
        let index = Int(scrollView.contentOffset.x / UIScreen.mainWidth())
        if index < 0 || index >= count { return }
        if CGFloat(index) * UIScreen.mainWidth() == scrollView.contentOffset.x {
            if index == currentIndex {
                for cell in collectionView.visibleCells {
                    storiesPlayerControllerMap[cell]?.play()
                }
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
            }
            for cell in collectionView.visibleCells {
                if let indexPath = collectionView.indexPath(for: cell), indexPath.row == currentIndex {
                    readPlayerControllerLoction(cell: cell)
                    storiesPlayerControllerMap[cell]?.reloadPlayer()
                }
            }
        }
    }
}