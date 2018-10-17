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
        let deltaY = abs(current.y - previous.y)
        let deltaX = abs(current.x - previous.x)
        if abs(offsetX) > threshold {
            if direction == .vertical {
                if deltaY > deltaX {
                    isDragging = true
                } else {
                    state = .failed
                }
            } else {
                if deltaY < deltaX {
                    isDragging = true
                } else {
                    state = .failed
                }
            }
        } else if abs(offsetY) > threshold {
            if direction == .horizontal {
                if deltaY < deltaX {
                    isDragging = true
                } else {
                    state = .failed
                }
            } else {
                if deltaY > deltaX {
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

class CustomPanGestureRecognizer: UIPanGestureRecognizer {
    enum Orientation {
        case up
        case down
        case left
        case right
    }
    
    let orientation: Orientation
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    private var isDragging = false
    
    init(orientation: Orientation, target: Any?, action: Selector?) {
        self.orientation = orientation
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
            setStates(current: current, previous: previous)
        } else if abs(offsetY) > threshold {
            setStates(current: current, previous: previous)
        }
    }
    
    private func setStates(current: CGPoint, previous: CGPoint) {
        let deltaY = abs(current.y - previous.y)
        let deltaX = abs(current.x - previous.x)
        if orientation == .up || orientation == .down {
            if deltaY > deltaX {
                if orientation == .up {
                    if current.y < previous.y {
                        isDragging = true
                    } else {
                        state = .failed
                    }
                } else {
                    if current.y > previous.y {
                        isDragging = true
                    } else {
                        state = .failed
                    }
                }
            } else {
                state = .failed
            }
        } else if orientation == .left || orientation == .right {
            if deltaY < deltaX {
                if orientation == .left {
                    if current.x < previous.x {
                        isDragging = true
                    } else {
                        state = .failed
                    }
                } else {
                    if current.x > previous.x {
                        isDragging = true
                    } else {
                        state = .failed
                    }
                }
            } else {
                state = .failed
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
