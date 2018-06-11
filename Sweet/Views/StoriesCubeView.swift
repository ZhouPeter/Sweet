//
//  StoriesCubeView.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol StoriesCubeViewDelegate: class {
    func cubeViewDidScroll(_ cubeView: StoriesCubeView)
}

class StoriesCubeView: UIScrollView, UIScrollViewDelegate {
    
    weak var cubeDelegate: StoriesCubeViewDelegate?
    
    fileprivate let maxAngle: CGFloat = 60.0
    
    fileprivate var childViews = [UIView]()
    
    fileprivate lazy var stackView: UIStackView = {
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = UILayoutConstraintAxis.horizontal
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureScrollView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func addChildViews(_ views: [UIView]) {
        
        for view in views {
            
            view.layer.masksToBounds = true
            stackView.addArrangedSubview(view)
            
            addConstraint(NSLayoutConstraint(
                item: view,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.width,
                multiplier: 1,
                constant: 0)
            )
            
            childViews.append(view)
        }
        
        /*
         let w = bounds.size.width
         let h = bounds.size.height
         
         for index in 0 ..< views.count {
         
         let view = views[index]
         
         view.frame = CGRectMake(CGFloat(index) * w, 0, w, h)
         view.layer.masksToBounds = true
         addSubview(view)
         
         childViews.append(view)
         }
         */
        //contentSize = CGSizeMake(CGFloat(childViews.count) * w, h)
    }
    
    func addChildView(_ view: UIView) {
        addChildViews([view])
    }
    
    func scrollToViewAtIndex(_ index: Int, animated: Bool) {
        if index > -1 && index < childViews.count {
            
            let width = self.frame.size.width
            let height = self.frame.size.height
            
            let frame = CGRect(x: CGFloat(index)*width, y: 0, width: width, height: height)
            scrollRectToVisible(frame, animated: animated)
        }
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        transformViewsInScrollView(scrollView)
        cubeDelegate?.cubeViewDidScroll(self)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setDefaultAnchorPoint()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setDefaultAnchorPoint()
    }
    // MARK: Private methods
  
    fileprivate func configureScrollView() {
        
        // Configure scroll view properties
        
        backgroundColor = UIColor.black
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isPagingEnabled = true
        bounces = true
        delegate = self
        
        // Add layout constraints
        
        addSubview(stackView)
        
        addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutAttribute.leading,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.leading,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.top,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.height,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.trailing,
            relatedBy: NSLayoutRelation.equal,
            toItem: stackView,
            attribute: NSLayoutAttribute.trailing,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: stackView,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1,
            constant: 0)
        )
    }
    
    fileprivate func transformViewsInScrollView(_ scrollView: UIScrollView) {
        
        let xOffset = scrollView.contentOffset.x
        let svWidth = scrollView.frame.width
        var deg = maxAngle / bounds.size.width * xOffset
        
        for index in 0 ..< childViews.count {
            
            let view = childViews[index]
            
            deg = index == 0 ? deg : deg - maxAngle
            let rad = deg * CGFloat(Double.pi / 180)
            
            var transform = CATransform3DIdentity
            transform.m34 = 1 / 500
            transform = CATransform3DRotate(transform, rad, 0, 1, 0)
            
            view.layer.transform = transform

            let pointX = xOffset / svWidth > CGFloat(index) ? 1.0 : 0.0
            setAnchorPoint(CGPoint(x: pointX, y: 0.5), forView: view)
            
            applyShadowForView(view, index: index)
        }
    }
    
    fileprivate func applyShadowForView(_ view: UIView, index: Int) {
        
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        let rect1 = frameFor(origin: contentOffset, size: self.frame.size)
        let rect2 = frameFor(origin: CGPoint(x: CGFloat(index)*width, y: 0),
                          size: CGSize(width: width, height: height))
        
        // Only show shadow on right-hand side
        if rect1.origin.x <= rect2.origin.x {
            
            let intersection = rect1.intersection(rect2)
            let intArea = intersection.size.width*intersection.size.height
            let union = rect1.union(rect2)
            let unionArea = union.size.width*union.size.height
            
            view.layer.opacity = Float(intArea / unionArea)
            
        }
    }
    
    fileprivate func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {
        
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x,
                               y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x,
                               y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint

    }
    
    fileprivate func setDefaultAnchorPoint() {
        for index in 0 ..< childViews.count {
            let view = childViews[index]
            let anchorPoint = CGPoint(x: 0.5, y: 0.5)
            let newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x,
                                   y: view.bounds.size.height * anchorPoint.y)
            let oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x,
                                   y: view.bounds.size.height * view.layer.anchorPoint.y)
            var position = view.layer.position
            position.x -= oldPoint.x
            position.x += newPoint.x
            position.y -= oldPoint.y
            position.y += newPoint.y
            view.layer.position = position
            view.layer.anchorPoint = anchorPoint
        }
    }
    fileprivate func frameFor(origin: CGPoint, size: CGSize) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }
}
