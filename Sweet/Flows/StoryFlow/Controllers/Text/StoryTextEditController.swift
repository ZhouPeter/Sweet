//
//  StoryTextEditController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable type_body_length
// swiftlint:disable file_length
// swiftlint:disable fallthrough

import UIKit

final class StoryTextEditController: UIViewController {
    weak var delegate: StoryTextEditControllerDelegate?
    var isTextViewEditing: Bool { return textView.isFirstResponder }
    var hasText: Bool { return textView.hasText }
    
    var topic: String? {
        didSet {
            if let topic = topic {
                topicButton.setAttributedTitle(NSMutableAttributedString(topic: topic, fontSize: 30), for: .normal)
                DispatchQueue.main.async { self.layoutTopicButton() }
            } else {
                topicButton.alpha = 0
            }
            keyboardControl.topicButton.updateTopic(topic ?? "添加标签")
        }
    }
    
    var boundingRect: CGRect {
        let frame = textBoundingView.frame
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        return CGRect(
            x: frame.minX / width,
            y: frame.minY / height,
            width: frame.width / width,
            height: frame.height / height
        )
    }
    
    private lazy var keyboardControl: StoryKeyboardControlView = {
        let control = StoryKeyboardControlView()
        control.delegate = self
        return control
    } ()
    
    private lazy var tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    private lazy var pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinched(_:)))
    private lazy var rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotated(_:)))
    private var isTextGestureEnabled = true
    private var textContainerEditScale: CGFloat = 1
    private var textTransform: Transform?
    private var topicButtonCenterX: NSLayoutConstraint?
    private var topicButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = #imageLiteral(resourceName: "TopicLabelBackground")
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 22), resizingMode: .stretch)
        button.setBackgroundImage(image, for: .normal)
        button.isUserInteractionEnabled = false
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.addTarget(self, action: #selector(didPressedTopicButton), for: .touchUpInside)
        return button
    } ()
    
    private var firstLineUsedRect = CGRect.zero { didSet { layoutTopicButton() } }
    
    private lazy var textBoundingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 115.0/255.0, blue: 225.0/255.0, alpha: 0.27)
        view.alpha = 0
        return view
    } ()
    
    private lazy var textViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        self.pinch.delegate = self
        view.addGestureRecognizer(pinch)
        self.rotation.delegate = self
        view.addGestureRecognizer(self.rotation)
        self.pan.delegate = self
        view.addGestureRecognizer(self.pan)
        return view
    } ()
    
    private lazy var textView: TextEditView = {
        let view = TextEditView(frame: .zero, textContainer: nil)
        view.textAlignment = self.paragraphStyle.alignment
        view.delegate = self
        self.tap.delegate = self
        view.addGestureRecognizer(tap)
        return view
    } ()
    
    private let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    } ()
    
    private var textContainerHeight: CGFloat {
        if UIScreen.isIphoneX() {
            return UIScreen.mainHeight() - UIScreen.safeTopMargin() - keyboardHeight
        }
        return view.bounds.height - keyboardHeight
    }
    
    private var safeTextHeight: CGFloat {
        let height = textView.hasText ? textView.contentSize.height : 100
        return ceil(textView.sizeThatFits(CGSize(width: textView.frame.width, height: height)).height)
    }
    
    private let keyboard = KeyboardObserver()
    private var keyboardHeight: CGFloat = 0
    private var keyboardControlBottom: NSLayoutConstraint?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(textBoundingView)
        
        view.addSubview(textViewContainer)
        textViewContainer.addSubview(textView)
        textViewContainer.addSubview(topicButton)
        
        topicButtonCenterX = topicButton.centerX(to: textView)
        topicButton.pin(.top, to: textView, spacing: 10)
        
        layoutTextContainer()
        textView.frame.size.width = textViewContainer.frame.width
        textView.frame.origin.x = 0
        layoutTextView()
        updateTextEditTransform(animated: false)
        layoutTextBoundingView()
        
        keyboard.observe { [weak self] in self?.handleKeyboardEvent($0) }
        
        view.addSubview(keyboardControl)
        keyboardControl.constrain(height: 40)
        keyboardControl.align(.left, to: view)
        keyboardControl.align(.right, to: view)
        keyboardControl.alpha = 0
        keyboardControlBottom = keyboardControl.align(.bottom, to: view)
        if topic == nil {
            topicButton.alpha = 0
        }
    }
    
    func clear() {
        textView.text = nil
        textTransform = nil
        textView.resignFirstResponder()
    }
    
    func beginEditing() {
        isEditing = true
        textView.becomeFirstResponder()
        delegate?.storyTextEditControllerDidBeginEditing()
    }
    
    func endEditing() {
        isEditing = false
        textView.resignFirstResponder()
        delegate?.storyTextEidtControllerDidEndEditing()
    }
    
    func deleteTextZone(at center: CGPoint) {
        let originCenter = view.center
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.view.center = center
            self.view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            self.view.alpha = 0
            self.topicButton.alpha = 0
        }, completion: { (_) in
            self.view.center = originCenter
            self.view.transform = .identity
            self.view.alpha = 1
            self.clear()
        })
    }
    
//    private lazy var debugAreaLayer: CAShapeLayer = {
//        let layer = CAShapeLayer()
//        layer.fillColor = UIColor.brown.cgColor
//        layer.frame = self.view.bounds
//        self.view.layer.insertSublayer(layer, at: 0)
//        return layer
//    } ()

    func makeTouchArea() -> [CGPoint]? {
        if topic == nil { return nil }
        let transform = textTransform?.makeCGAffineTransform() ?? CGAffineTransform.identity
        let topicOffset = CGPoint(x: topicButton.center.x - textView.center.x,
                                  y: topicButton.center.y - textView.center.y)
        var center = textView.center
        center.x += (textTransform?.translation.x ?? 0)
        center.y += (textTransform?.translation.y ?? 0)
        center = center.applying(transform.inverted())
        center.x += topicOffset.x
        center.y += topicOffset.y
        let halfWidth = topicButton.bounds.width * 0.5
        let halfHeight = topicButton.bounds.height * 0.5
        let topLeft = CGPoint(
            x: center.x - halfWidth,
            y: center.y - halfHeight
        ).applying(transform)
        let topRight = CGPoint(
            x: center.x + halfWidth,
            y: center.y - halfHeight
            ).applying(transform)
        let bottomLeft = CGPoint(
            x: center.x - halfWidth,
            y: center.y + halfHeight
            ).applying(transform)
        let bottomRight = CGPoint(
            x: center.x + halfWidth,
            y: center.y + halfHeight
            ).applying(transform)
        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.addLine(to: topLeft)
        path.close()
//        debugAreaLayer.path = path.cgPath
        let width = view.bounds.width
        let height = view.bounds.height
        let scaled: (CGPoint) -> CGPoint = { return CGPoint(x: $0.x / width, y: $0.y / height) }
        
        return [scaled(topLeft), scaled(topRight), scaled(bottomRight), scaled(bottomLeft)]
    }
    
    // MARK: - Private
    
    private func layoutTopicButton() {
        if textView.hasText {
            topicButtonCenterX?.constant = (topicButton.bounds.width - firstLineUsedRect.size.width) * 0.5
        } else {
            topicButtonCenterX?.constant = 0
        }
    }
    
    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            let screenHeight = UIScreen.main.bounds.height
            keyboardHeight = screenHeight - event.keyboardFrameEnd.origin.y
            let frame = view.convert(view.frame, to: UIApplication.shared.keyWindow!)
            logger.debug(frame)
            keyboardControlBottom?.constant = -(keyboardHeight - (screenHeight - frame.maxY))
            UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                if event.type == .willShow {
                    self.keyboardControl.alpha = 1
                    self.topicButton.alpha = 0
                } else if event.type == .willHide {
                    self.keyboardControl.alpha = 0
                    self.topicButton.alpha = self.topic == nil ? 0 : 1
                }
                self.view.layoutIfNeeded()
                self.layoutTextContainer()
                self.layoutTextView()
            }, completion: nil)
        default:
            break
        }
        if event.type == .willShow {
            isTextGestureEnabled = false
            transformTextContainer(
                CATransform3DMakeScale(textContainerEditScale, textContainerEditScale, 1),
                animated: true
            )
        } else if event.type == .willHide {
            isTextGestureEnabled = textView.hasText || topic != nil
            doTextDisplayTransform()
        }
    }
    
    private func layoutTextContainer() {
        textViewContainer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: textContainerHeight)
    }
    
    private func layoutTextView() {
        let textHeight = safeTextHeight
        var frame = textView.frame
        frame.origin.y = ceil((textContainerHeight - textHeight) * 0.5)
        frame.size.height = textHeight
        textView.frame = frame
        // fix content offset error
        textView.setContentOffset(.zero, animated: false)
        textView.setContentOffset(.zero, animated: true)
    }
    
    private func layoutTextBoundingView() {
        var rect = CGRect.zero
        var transform = CGAffineTransform.identity
        var center = textView.center
        if let textTransform = textTransform {
            transform = textTransform.makeCGAffineTransform()
            center.x += textTransform.translation.x
            center.y += textTransform.translation.y
        }
        rect = textView.frame.applying(transform)
        let length = max(max(rect.width, rect.height), 100)
        rect.size.width = length
        rect.size.height = length
        textBoundingView.frame = rect
        textBoundingView.center = view.convert(center, from: textViewContainer)
    }
    
    private func makeTextDeleteZone() -> CGRect {
        var rect = textBoundingView.frame
        rect.size.width = min(rect.size.width, 100)
        rect.size.height = min(rect.size.height, 100)
        rect.origin.x = textBoundingView.center.x - rect.width * 0.5
        rect.origin.y = textBoundingView.center.y - rect.height * 0.5
        return rect
    }
    
    private func updateTextEditTransform(animated: Bool) {
        let textHeight = safeTextHeight
        let containerHeight = textContainerHeight
        var transform = CATransform3DIdentity
        if textHeight > containerHeight {
            textContainerEditScale = containerHeight / textHeight
            transform = CATransform3DMakeScale(textContainerEditScale, textContainerEditScale, 1)
        }
        transformTextContainer(transform, animated: animated)
    }
    
    private func doTextDisplayTransform(animated: Bool = false) {
        if let textTransform = textTransform {
            transformTextContainer(textTransform.make3DTransform(), animated: animated)
        } else {
            transformTextContainer(CATransform3DIdentity, animated: animated)
        }
        layoutTextBoundingView()
    }
    
    private func transformTextContainer(_ transform: CATransform3D, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "sublayerTransform")
            animation.duration = 0.25
            animation.fromValue = textViewContainer.layer.presentation()?.sublayerTransform
            animation.toValue = transform
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            textViewContainer.layer.add(animation, forKey: "sublayerTransform")
        }
        textViewContainer.layer.sublayerTransform = transform
    }
    
    private func hideBoundingView(isHidden: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.textBoundingView.alpha = isHidden ? 0 : 0.5
        }, completion: nil)
    }
    
    private func gestureDidBegin() {
        #if DEBUG
        hideBoundingView(isHidden: false)
        #endif
    }
    
    private func gestureDidEnd() {
        #if DEBUG
        hideBoundingView(isHidden: true)
        #endif
    }
    
    // MARK: - Actions
    
    @objc private func didPressedTopicButton() {
        guard topic != nil, textView.isFirstResponder == false else { return }
        textView.becomeFirstResponder()
    }
    
    @objc private func tapped(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended && textView.isFirstResponder == false {
            textView.becomeFirstResponder()
        }
    }
    
    private var isPanTextView = false
    
    @objc private func panned(_ gesture: UIPanGestureRecognizer) {
        guard isTextGestureEnabled else { return }
        if gesture.state == .began {
            isPanTextView = false
            if pan.numberOfTouches > 1 || isPanLocatedInTextView() {
                isPanTextView = textView.hasText || topic != nil
            }
            if isPanTextView {
                gestureDidBegin()
                delegate?.storyTextEditControllerTextDeleteZoneDidBeginUpdate(makeTextDeleteZone())
            } else {
                delegate?.storyTextEditControllerDidPan(pan)
                return
            }
        }
        if gesture.state == .ended {
            gestureDidEnd()
            if isPanTextView {
                delegate?.storyTextEditControllerTextDeleteZoneDidEndUpdate(makeTextDeleteZone())
            } else {
                delegate?.storyTextEditControllerDidPan(pan)
            }
            return
        }
        if isPanTextView {
            let translation = gesture.translation(in: view)
            if textTransform == nil {
                textTransform = Transform()
                textTransform?.scale = textContainerEditScale
            }
            textTransform?.translation.x += translation.x
            textTransform?.translation.y += translation.y
            gesture.setTranslation(.zero, in: view)
            doTextDisplayTransform()
            delegate?.storyTextEditControllerTextDeleteZoneDidUpdate(makeTextDeleteZone())
        } else {
            delegate?.storyTextEditControllerDidPan(pan)
        }
    }
    
    @objc private func pinched(_ gesture: UIPinchGestureRecognizer) {
        guard isTextGestureEnabled else { return }
        switch gesture.state {
        case .began:
            gestureDidBegin()
            fallthrough
        case .changed:
            if textTransform == nil {
                textTransform = Transform()
                textTransform?.scale = textContainerEditScale
            }
            textTransform?.scale *= gesture.scale
            gesture.scale = 1
            doTextDisplayTransform()
        default:
            gestureDidEnd()
        }
    }
    
    @objc private func rotated(_ gesture: UIRotationGestureRecognizer) {
        guard isTextGestureEnabled else { return }
        switch gesture.state {
        case .began:
            gestureDidBegin()
            fallthrough
        case .changed:
            if textTransform == nil {
                textTransform = Transform()
                textTransform?.scale = textContainerEditScale
            }
            textTransform?.rotation += gesture.rotation
            gesture.rotation = 0
            doTextDisplayTransform()
        default:
            gestureDidEnd()
        }
    }

    private func isPanLocatedInTextView() -> Bool {
        return textBoundingView.frame.insetBy(dx: -20, dy: -20).contains(pan.location(ofTouch: 0, in: view))
    }
}

extension StoryTextEditController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension StoryTextEditController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !isEditing {
            isEditing = true
            delegate?.storyTextEditControllerDidBeginEditing()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let layoutManager = textView.layoutManager
        let layoutRange = NSRange(location: 0, length: layoutManager.numberOfGlyphs)
        var lineRange: NSRange?
        layoutManager.enumerateLineFragments(forGlyphRange: layoutRange) { (_, _, _, glyphRange, stop) in
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            if range.length == 0 {
                // insert
                if range.location == glyphRange.location + glyphRange.length {
                    lineRange = characterRange
                } else if NSLocationInRange(range.location, glyphRange) {
                    lineRange = characterRange
                }
            } else {
                // delete
                if NSLocationInRange(range.location, glyphRange) {
                    lineRange = characterRange
                }
            }
            if lineRange != nil {
                stop.pointee = true
            }
        }
        
        guard let characterRange = lineRange else { return true }
        let string = (textView.text as NSString).substring(with: characterRange)
        let newRange = NSRange(location: range.location - characterRange.location, length: 0)
        let typingLineString = (string as NSString).replacingCharacters(in: newRange, with: text)
        let textStorage = textView.textStorage
        textStorage.beginEditing()
        let fontSize = self.calculateFontSize(with: typingLineString)
        textStorage.setAttributes(
            [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ],
            range: characterRange
        )
        textStorage.endEditing()
        
        var typingAttributes = textView.typingAttributes
        typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont.systemFont(ofSize: fontSize)
        textView.typingAttributes = typingAttributes
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextStorageFontSize()
        layoutTextView()
        updateTextEditTransform(animated: true)
    }
    
    private func adjustTextStorageFontSize() {
        let layoutManager = textView.layoutManager
        let range = NSRange(location: 0, length: layoutManager.numberOfGlyphs)
        var ranges = [NSValue]()
        var isFirstLine = true
        layoutManager.enumerateLineFragments(forGlyphRange: range) { (_, usedRect, _, glyphRange, _) in
            if isFirstLine {
                isFirstLine = false
                self.firstLineUsedRect = usedRect
            }
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            ranges.append(NSValue(range: characterRange))
        }
        let textStorage = textView.textStorage
        textStorage.beginEditing()
        ranges.forEach { (value) in
            let range = value.rangeValue
            let string = (self.textView.text as NSString).substring(with: range)
            let fontSize = self.calculateFontSize(with: string)
            textStorage.setAttributes(
                [
                    .font: UIFont.systemFont(ofSize: fontSize),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraphStyle
                ],
                range: range
            )
        }
        textStorage.endEditing()
    }
    
    private func calculateFontSize(with string: String) -> CGFloat {
        guard string.count > 1 else { return FontSize.max }
        let fontSize = FontSize.max
        let attributedString = NSAttributedString(
            string: string,
            attributes: [.font: UIFont.systemFont(ofSize: fontSize)]
        )
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let textWidth = attributedString.boundingRect(with: maxSize, options: [], context: nil).width
        let textRenderWidth = textView.bounds.width - FontSize.min
        let scaleFactor = textRenderWidth / textWidth
        let preferredFontSize = fontSize * scaleFactor
        return min(max(FontSize.min, preferredFontSize), FontSize.max)
    }
}

extension StoryTextEditController: StoryKeyboardControlViewDelegate {
    func keyboardControlViewDidPressNextButton() {
        endEditing()
    }
    
    func keyboardControlViewDidPressTopicButton() {
        delegate?.storyTextEditControllerDidBeginChooseTopic()
        
        textView.resignFirstResponder()
        
        let topic = TopicListController()
        addChildViewController(topic)
        topic.didMove(toParentViewController: self)
        view.addSubview(topic.view)
        topic.view.frame = view.bounds
        topic.view.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            topic.view.alpha = 1
            self.textViewContainer.alpha = 0
        }, completion: nil)
        let dismissTopic: (String?) -> Void = { [weak self] topic in
            guard let `self` = self, let view = self.view.snapshotView(afterScreenUpdates: false) else { return }
            self.view.addSubview(view)
            self.textView.becomeFirstResponder()
            view.frame = self.view.bounds
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                view.alpha = 0
                self.textViewContainer.alpha = 1
            }, completion: { (_) in
                self.delegate?.storyTextEditControllerDidEndChooseTopic(topic)
                view.removeFromSuperview()
            })
        }
        topic.onFinished = { [weak self] topic in
            self?.topic = topic
            dismissTopic(topic)
        }
        topic.onCancelled = { dismissTopic(nil) }
    }
}
