//
//  OnboardingController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Hero

final class OnboardingController: BaseViewController, OnboardingView {
    static let wasShownKey = "onboardingWasShownKey"
    var onFinish: (() -> Void)?
    override var prefersStatusBarHidden: Bool { return true }
    private var flag = false
    private var count = 5
    private var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setScrollView()
        setPageControl()
    }
    
    private func setScrollView() {
        let width = UIScreen.mainWidth()
        let height = UIScreen.mainHeight()
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        view.addSubview(scrollView)
        for index in 0..<count {
            let prefix = UIScreen.isIphoneX() ? "SlideX" : "Slide"
            let image = UIImage(named: "\(prefix)\(index + 1)")
            let imageView = UIImageView(frame: CGRect(x: width * CGFloat(index), y: 0, width: width, height: height))
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            scrollView.addSubview(imageView)
            if index == count - 1 {
                let button = ShrinkButton()
                button.setTitle("进入讲真", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor.xpNavBlue()
                button.addTarget(self, action: #selector(didPressFinishButton), for: .touchUpInside)
                button.clipsToBounds = true
                button.layer.cornerRadius = 25
                imageView.addSubview(button)
                button.align(.bottom, to: imageView, inset: 100)
                button.align(.left, to: imageView, inset: 28)
                button.align(.right, to: imageView, inset: 28)
                button.constrain(height: 50)
                imageView.isUserInteractionEnabled = true
            }
        }
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: width * CGFloat(count), height: height)
        scrollView.delegate = self
    }
    
    private func setPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = count
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor =
            UIColor(red: 216 / 255.0, green: 216 / 255.0, blue: 216 / 255.0, alpha: 0.5)
        view.addSubview(pageControl)
        pageControl.centerX(to: view)
        pageControl.align(.bottom, to: view)
    }
    
    @objc private func didPressFinishButton() {
        flag = true
        let def = UserDefaults.standard
        def.set(flag, forKey: OnboardingController.wasShownKey)
        def.synchronize()
        hero.isEnabled = true
        hero.modalAnimationType = .fade
        onFinish?()
    }
}

extension OnboardingController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        if page == count - 1 {
            pageControl.isHidden = true
        } else {
            pageControl.isHidden = false
        }
        pageControl.currentPage = page
    }
}
