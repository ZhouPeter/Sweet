//
//  UIView+Layout.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    @discardableResult func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension UIView {
    public enum Align {
        case left
        case right
        case top
        case bottom
    }
    
    public enum Edge {
        case left
        case right
        case top
        case bottom
    }
    
    public enum Size {
        case width
        case height
        case size
    }
    
    public typealias SizeConstraints = (width: NSLayoutConstraint?, height: NSLayoutConstraint?)
    
    public func fill(in view: UIView, left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
        align(.left, to: view, inset: left)
        align(.right, to: view, inset: right)
        align(.top, to: view, inset: top)
        align(.bottom, to: view, inset: bottom)
    }
    
    public func center(in view: UIView, width: CGFloat, height: CGFloat, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        constrain(width: width, height: height)
        centerX(to: view, offset: xOffset)
        centerY(to: view, offset: yOffset)
    }
    
    @discardableResult public func centerX(to view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult public func centerY(to view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
    public func center(to view: UIView, offsetX: CGFloat = 0, offsetY: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offsetX).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offsetY).isActive = true
    }
    
    public func constrain(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    @discardableResult public func constrain(height: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalToConstant: height)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult public func constrain(width: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalToConstant: width)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult public func equal(
        _ size: Size,
        to anchorView: UIView,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0) -> SizeConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: SizeConstraints = (nil, nil)
        if size == .width || size == .size {
            constraints.width = widthAnchor.constraint(equalTo: anchorView.widthAnchor,
                                                       multiplier: multiplier,
                                                       constant: offset)
            constraints.width?.isActive = true
        }
        if size == .height || size == .size {
            constraints.height = heightAnchor.constraint(equalTo: anchorView.heightAnchor,
                                                         multiplier: multiplier,
                                                         constant: offset)
            constraints.height?.isActive = true
        }
        return constraints
    }
    
    @discardableResult public func align(
        _ align: Align,
        to view: UIView? = nil,
        inset: CGFloat = 0,
        priority: UILayoutPriority = .required ) -> NSLayoutConstraint {
        let anchorView = view ?? superview!
        translatesAutoresizingMaskIntoConstraints = false
        let constraint: NSLayoutConstraint
        switch align {
        case .left:
            constraint = leftAnchor.constraint(equalTo: anchorView.leftAnchor, constant: inset)
        case .right:
            constraint = rightAnchor.constraint(equalTo: anchorView.rightAnchor, constant: -inset)
        case .top:
            constraint = topAnchor.constraint(equalTo: anchorView.topAnchor, constant: inset)
        case .bottom:
            constraint = bottomAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: -inset)
        }
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult public func pin(
        _ edge: Edge,
        to anchorView: UIView,
        spacing: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint: NSLayoutConstraint
        switch edge {
        case .left:
            constraint = rightAnchor.constraint(equalTo: anchorView.leftAnchor, constant: -spacing)
        case .right:
            constraint = leftAnchor.constraint(equalTo: anchorView.rightAnchor, constant: spacing)
        case .top:
            constraint = bottomAnchor.constraint(equalTo: anchorView.topAnchor, constant: -spacing)
        case .bottom:
            constraint = topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: spacing)
        }
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
}
