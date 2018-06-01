//
//  StoriesPlayerGroupViewController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class StoriesPlayerGroupViewController: BaseViewController {
    
    var currentIndex = 0
    var subCurrentIndex = 0
    var storiesGroup: [[StoryCellViewModel]]?

    private lazy var cubeView: StoriesCubeView = {
        let cubeView = StoriesCubeView()
        cubeView.translatesAutoresizingMaskIntoConstraints = false
        cubeView.cubeDelegate = self
        return cubeView
    }()
    
    private var storiesPlayerControllers = [StoriesPlayerViewController]()
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
        if let storiesGroup = storiesGroup {
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
                cubeView.addChildView(playerController.view)
            }
            cubeView.layoutIfNeeded()
            cubeView.scrollToViewAtIndex(currentIndex, animated: false)
        }
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
        if let storiesGroup = storiesGroup, currentIndex + 1 > storiesGroup.count - 1 { return }
        cubeView.scrollToViewAtIndex(currentIndex + 1, animated: true)
    }
}
extension StoriesPlayerGroupViewController: StoriesCubeViewDelegate {
    func cubeViewDidScroll(_ cubeView: StoriesCubeView) {
        guard  let count = storiesGroup?.count  else { return }
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
