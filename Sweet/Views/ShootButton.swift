//
//  ShootButton.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class ShootButton: UIButton {
    var trackingDidStart: (() -> Void)?
    var trackingDidEnd: ((TimeInterval) -> Void)?
    var touchInterval: TimeInterval = 10
    
    private var displayLink: CADisplayLink?
    
    private let innerCircle: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor(white: 1, alpha: 0.9).cgColor
        layer.strokeColor = nil
        return layer
    } ()
    
    private let outerCircle: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor(white: 1, alpha: 0.4).cgColor
        layer.strokeColor = nil
        return layer
    } ()
    
    private let progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = UIColor(hex: 0x56BFFE).cgColor
        layer.strokeEnd = 0
        layer.opacity = 0.8
        layer.transform = CATransform3DMakeRotation(-CGFloat.pi * 0.5, 0, 0, 1)
        return layer
    } ()
    
    private var trackingStart: Date?
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        outerCircle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.addSublayer(outerCircle)
        outerCircle.addSublayer(progressLayer)
        outerCircle.addSublayer(innerCircle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let outerInset: CGFloat = 5
        let outerPathBounds = bounds.insetBy(dx: outerInset, dy: outerInset)
        let outerPath = UIBezierPath(ovalIn: outerPathBounds)
        outerCircle.path = outerPath.cgPath
        outerCircle.bounds = bounds
        outerCircle.position = CGPoint(x: bounds.midX, y: bounds.midY)
        innerCircle.frame = outerCircle.bounds
        let innerInset: CGFloat = 5
        let innerPathBounds = bounds.insetBy(dx: outerInset + innerInset, dy: outerInset + innerInset)
        let innerPath = UIBezierPath(ovalIn: innerPathBounds)
        innerCircle.path = innerPath.cgPath
        let lineWidth = (outerPathBounds.width - innerPathBounds.width) * 0.5
        let progressBounds = innerPathBounds.insetBy(dx: -lineWidth * 0.5, dy: -lineWidth * 0.5)
        let progressPath = UIBezierPath(ovalIn: progressBounds)
        progressLayer.path = progressPath.cgPath
        progressLayer.bounds = progressBounds
        progressLayer.position = CGPoint(x: outerPathBounds.midX, y: outerPathBounds.midY)
        progressLayer.lineWidth = lineWidth
    }
    
    func resetProgress() {
        outerCircle.transform = CATransform3DIdentity
        progressLayer.strokeEnd = 0
    }
    
    // MARK: - Private
    
    @objc private func updateProgress() {
        guard isTracking, let start = trackingStart else { return }
        let interval = Date().timeIntervalSince(start)
        let progress = CGFloat(interval / touchInterval)
        if interval >= touchInterval {
            progressLayer.strokeEnd = 1
            trackingDidEnd?(touchInterval)
            stopTimer()
            trackingStart = nil
            return
        }
        progressLayer.strokeEnd = progress
    }
    
    private func startTimer() {
        trackingStart = Date()
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .current, forMode: .commonModes)
    }
    
    private func stopTimer() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: - Touch Tracking
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        outerCircle.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        startTimer()
        trackingDidStart?()
        return super.beginTracking(touch, with: event)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let start = trackingStart {
            let interval = Date().timeIntervalSince(start)
            trackingDidEnd?(interval)
        }
        stopTimer()
    }
}
