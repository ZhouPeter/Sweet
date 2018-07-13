//
//  StoriesPlayerScrollView.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation


protocol StoriesPlayerScrollViewDelegate: NSObjectProtocol {
    func playScrollView(scrollView: StoriesPlayerScrollView, currentPlayerIndex: Int)
    func playToBack()
    func playToNext()
}

class StoriesPlayerScrollView: UIScrollView {
    var currentIndex: Int = 0
    var middleImageView: UIImageView!
    var scrollViewTap: UITapGestureRecognizer!
    private var stories = [StoryCellViewModel]()
    private var middleStory: StoryCellViewModel!
    private var isEnabled = true
    weak var playerDelegate: StoriesPlayerScrollViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView(frame: frame)
        addImageView(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView(frame: CGRect) {
        contentSize.width = frame.size.width
        isUserInteractionEnabled = true
        contentOffset.x = 0
        isScrollEnabled = false
        isOpaque = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapAction(_:)))
        addGestureRecognizer(scrollViewTap)
    }
    
    @objc private func scrollViewTapAction(_ tap: UITapGestureRecognizer) {
        guard isEnabled else { return }
        let point = tap.location(in: self)
        let leftRect = CGRect(x: 0, y: 0, width: UIScreen.mainWidth() / 3, height: UIScreen.mainHeight())
        isEnabled = false
        if leftRect.contains(point) {
            if currentIndex == 0 {
                playerDelegate?.playToBack()
                isEnabled = true
                return
            }
            currentIndex -=  1
            switchPlayer()
        } else {
            if currentIndex == stories.count - 1 {
                playerDelegate?.playToNext()
                isEnabled = true
                return
            }
            currentIndex += 1
            switchPlayer()
        }
    }
    
    private func addImageView(frame: CGRect) {
        middleImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        middleImageView.backgroundColor = .black
        middleImageView.contentMode = .scaleAspectFill
        middleImageView.clipsToBounds = true
        middleImageView.isUserInteractionEnabled = true
        addSubview(middleImageView)
    }
}

// MARK: - uploadPlayer

extension StoriesPlayerScrollView {
    func updateForStories(stories: [StoryCellViewModel], currentIndex: Int) {
        if stories.count > 0 {
            self.stories.removeAll()
            self.stories.append(contentsOf: stories)
            self.currentIndex = currentIndex
        }
        middleStory = self.stories[self.currentIndex]
        prepare(imageView: middleImageView, withStory: middleStory)
    }
    
    func switchPlayer() {
        isEnabled = true
        middleStory = self.stories[self.currentIndex]
        prepare(imageView: middleImageView, withStory: middleStory)
        playerDelegate?.playScrollView(scrollView: self, currentPlayerIndex: currentIndex)
    }
    
    private func prepare(imageView: UIImageView, withStory: StoryCellViewModel?) {
        if let story = withStory {
            if let videoURL = story.videoURL {
                imageView.kf.setImage(with: videoURL.videoThumbnail())
            } else if let imageURL = story.imageURL {
                imageView.kf.setImage(with: imageURL.imageView2(size: imageView.bounds.size))
            }
        } else {
            imageView.image = nil
        }
    }
}
