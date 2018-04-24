//
//  OnboardingController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class OnboardingController: BaseViewController, OnboardingView {
    static let wasShownKey = "onboardingWasShownKey"
    var onFinish: (() -> Void)?
    private var flag = false
    private var count = 4
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
        for index in 0..<count {
            let prefix = UIScreen.isIphoneX() ? "guide_x_" : "guide_"
            let image = UIImage(named: "\(prefix)\(index + 1)")
            let imageView = UIImageView(frame: CGRect(x: width * CGFloat(index), y: 0, width: width, height: height))
            imageView.image = image
            if index == count - 1 {
                let finishButton = UIButton()
                finishButton.frame = CGRect(x: 0, y: height - 100, width: width, height: 100)
                finishButton.addTarget(self, action: #selector(didPressFinishButton), for: .touchUpInside)
                imageView.addSubview(finishButton)
                imageView.isUserInteractionEnabled = true
                finishButton.isUserInteractionEnabled = true
            }
            scrollView.addSubview(imageView)
        }
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: width * CGFloat(count), height: height)
        scrollView.delegate = self
        view.addSubview(scrollView)
        
    }
    
    private func setPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = count
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor(red: 216 / 255.0, green: 216 / 255.0, blue: 216 / 255.0,
                                                     alpha: 0.5)
        pageControl.frame = CGRect.init(x: (UIScreen.mainWidth() - 100) / 2,
                                         y: UIScreen.mainHeight() - 30,
                                         width: 100,
                                         height: 10)
        view.addSubview(pageControl)
    }
    
    @objc private func didPressFinishButton() {
        flag = true
        let def = UserDefaults.standard
        def.set(flag, forKey: OnboardingController.wasShownKey)
        def.synchronize()
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
