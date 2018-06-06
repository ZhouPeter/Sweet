//
//  StoriesPlayerGroupViewController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol StoriesPlayerGroupViewControllerDelegate: NSObjectProtocol {
    func readGroup(storyGroupIndex index: Int)
}
class StoriesPlayerGroupViewController: BaseViewController {
    weak var delegate: StoriesPlayerGroupViewControllerDelegate?
    var currentIndex: Int {
        didSet {
            delegate?.readGroup(storyGroupIndex: currentIndex)
        }
    }
    var storiesGroup: [[StoryCellViewModel]]
    var subCurrentIndex = 0
    private lazy var cubeView: StoriesCubeView = {
        let cubeView = StoriesCubeView()
        cubeView.translatesAutoresizingMaskIntoConstraints = false
        cubeView.cubeDelegate = self
        return cubeView
    }()
    
    private var storiesPlayerControllers = [StoriesPlayerViewController]()
    
    init(storiesGroup: [[StoryCellViewModel]], currentIndex: Int) {
        self.storiesGroup = storiesGroup
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
//        self.setValue(currentIndex, forKey: "currentIndex")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cubeView)
        cubeView.fill(in: view)
        setChildViewController()
        storiesPlayerControllers[currentIndex].initPlayer()
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setChildViewController() {
        for index in 0 ..< storiesGroup.count {
            let stories = storiesGroup[index]
            let playerController = StoriesPlayerViewController()
            playerController.delegate = self
            playerController.stories = stories
            if index == currentIndex {
                playerController.currentIndex = subCurrentIndex
            } else {
                playerController.currentIndex = 0
            }
            storiesPlayerControllers.append(playerController)
            add(childViewController: playerController, addView: false)
            cubeView.addChildView(playerController.view)
        }
        cubeView.layoutIfNeeded()
        cubeView.scrollToViewAtIndex(currentIndex, animated: false)
    }
    
    private func setOldPlayerControllerLoction() {
        let viewController = storiesPlayerControllers[currentIndex]
        if viewController.currentIndex == viewController.stories.count - 1 {
            viewController.currentIndex = 0
        } else {
            viewController.currentIndex += 1
        }
    }
}

extension StoriesPlayerGroupViewController: StoriesPlayerViewControllerDelegate {
    func dismissController() {
        dismiss(animated: false, completion: nil)
    }
    
    func playToBack() {
        if currentIndex - 1 < 0 { return }
        cubeView.scrollToViewAtIndex(currentIndex - 1, animated: true)
    }
    
    func playToNext() {
        if currentIndex + 1 > storiesGroup.count - 1 { return }
        cubeView.scrollToViewAtIndex(currentIndex + 1, animated: true)
    }
}
extension StoriesPlayerGroupViewController: StoriesCubeViewDelegate {
    func cubeViewDidScroll(_ cubeView: StoriesCubeView) {
        let count = storiesGroup.count
        storiesPlayerControllers[currentIndex].pause()
        let index = Int(cubeView.contentOffset.x / UIScreen.mainWidth())
        if index < 0 || index >= count { return }
        if CGFloat(index) * UIScreen.mainWidth() == cubeView.contentOffset.x {
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

}
