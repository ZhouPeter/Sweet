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
        contentOffset.x  =  0
        isScrollEnabled = false
        isOpaque = true
        backgroundColor = .yellow
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapAction(_:)))
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
        middleImageView.contentMode = .scaleAspectFill
        middleImageView.clipsToBounds = true
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
            if let urlString = story.videoURL?.absoluteString {
                let imageUrlString = urlString + "?vframe/jpg/offset/0.5/w/375/h/667"
                imageView.kf.setImage(with: URL(string: imageUrlString))
            } else if let URL = story.imageURL {
                imageView.kf.setImage(with: URL)
            }
        } else {
            imageView.image = nil
        }
    }
}