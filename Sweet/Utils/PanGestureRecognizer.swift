//
//  PanGestureRecognizer.swift
//  XPro
//
//  Created by Mario Z. on 2018/1/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class PanGestureRecognizer: UIPanGestureRecognizer {
    enum Direction {
        case vertical
        case horizontal
    }
    
    let direction: Direction
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    private var isDragging = false
    
    init(direction: Direction, target: Any?, action: Selector?) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard state != .failed, isDragging == false, let touch = touches.first else { return }
        let current = touch.location(in: view)
        let previous = touch.previousLocation(in: view)
        offsetX += previous.x - current.x
        offsetY += previous.y - current.y
        let threshold: CGFloat = 5
        if abs(offsetX) > threshold {
            if direction == .vertical {
                if abs(current.y - previous.y) > abs(current.x - previous.x) {
                    isDragging = true
                } else {
                    state = .failed
                }
            } else {
                if abs(current.y - previous.y) < abs(current.x - previous.x) {
                    isDragging = true
                }
            }
        } else if abs(offsetY) > threshold {
            if direction == .horizontal {
                if abs(current.y - previous.y) < abs(current.x - previous.x) {
                    isDragging = true
                } else {
                    state = .failed
                }
            } else {
                if abs(current.y - previous.y) > abs(current.x - previous.x) {
                    isDragging = true
                } else {
                    state = .failed
                }
            }
        }
    }
    
    override func reset() {
        super.reset()
        isDragging = false
        offsetX = 0
        offsetY = 0
    }
}