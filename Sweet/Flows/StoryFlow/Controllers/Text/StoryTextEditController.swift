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

protocol StoryTextEditControllerDelegate: class {
    func storyTextEditControllerDidBeginEditing()
    func storyTextEidtControllerDidEndEditing()
    func storyTextEditControllerDidPan(_ pan: UIPanGestureRecognizer)
    func storyTextEditControllerTextDeleteZoneDidUpdate(_ rect: CGRect)
    func storyTextEditControllerTextDeleteZoneDidEndUpdate(_ rect: CGRect)
}

extension StoryTextEditControllerDelegate {
    func storyTextEditControllerTextDeleteZoneDidUpdate(_ rect: CGRect) {}
    func storyTextEditControllerTextDeleteZoneDidEndUpdate(_ rect: CGRect) {}
}

final class StoryTextEditController: UIViewController {
    var topic: Topic? {
        didSet {
            if let topic = topic {
                topicButton.setTitle("#" + topic.content, for: .normal)
                topicButton.alpha = 1
            } else {
                topicButton.alpha = 0
            }
        }
    }
    weak var delegate: StoryTextEditControllerDelegate?
    var hidesTopicWithoutText = false
    let keyboardControl = StoryKeyboardControlView()
    
    private lazy var tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    private lazy var pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinched(_:)))
    private lazy var rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotated(_:)))
    private var isTextGestureEnabled = true
    private var textContainerEditScale: CGFloat = 1
    private var textTransform: TextTransform?
    private var topicButtonLeft: NSLayoutConstraint?
    private var topicButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hex: 0xF8E71C), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        button.setTitle("#你好", for: .normal)
        let image = #imageLiteral(resourceName: "TopicLabelBackground")
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 22), resizingMode: .stretch)
        button.setBackgroundImage(image, for: .normal)
        button.isUserInteractionEnabled = false
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.alpha = 0
        return button
    } ()
    
    private var firstLineUsedRect = CGRect.zero {
        didSet {
            topicButtonLeft?.constant = firstLineUsedRect.origin.x
        }
    }
    
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
    
    private lazy var textView: UITextView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = .clear
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: FontSize.min)
        view.textAlignment = self.paragraphStyle.alignment
        view.delegate = self
        view.textContainerInset = .zero
        self.tap.delegate = self
        view.addGestureRecognizer(tap)
        view.enableShadow()
        view.clipsToBounds = true
        return view
    } ()
    
    private let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    } ()
    
    private var textContainerHeight: CGFloat {
        return view.bounds.height - keyboardHeight
    }
    
    private var safeTextHeight: CGFloat {
        let height = textView.hasText ? textView.contentSize.height : 100
        // fix content size error
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
        
        topicButtonLeft = topicButton.align(.left, to: textView)
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
    }
    
    func clear() {
        textView.text = nil
        textTransform = nil
        textView.resignFirstResponder()
    }
    
    func beginEditing() {
        textView.becomeFirstResponder()
    }
    
    func endEditing() {
        textView.resignFirstResponder()
    }
    
    var isTextViewEditing: Bool {
        return textView.isFirstResponder
    }
    
    var hasText: Bool {
        return textView.hasText
    }
    
    func deleteTextZone(at center: CGPoint) {
        let originCenter = view.center
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.view.center = center
            self.view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            self.view.alpha = 0
        }, completion: { (_) in
            self.view.center = originCenter
            self.view.transform = .identity
            self.view.alpha = 1
            self.clear()
        })
    }
    
    // MARK: - Private
    
    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            keyboardHeight = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
            keyboardControlBottom?.constant = -keyboardHeight
            UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                if !self.textView.hasText {
                    if self.hidesTopicWithoutText {
                        self.topicButton.alpha = 0
                    }
                }
                if event.type == .willShow {
                    self.keyboardControl.alpha = 1
                } else if event.type == .willHide {
                    self.keyboardControl.alpha = 0
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
            isTextGestureEnabled = textView.hasText
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
        var transform = CGAffineTransform.identity
        var center = textView.center
        if let textTransform = textTransform {
            transform = textTransform.makeCGAffineTransform()
            center.x += textTransform.translation.x
            center.y += textTransform.translation.y
        }
        var rect = textView.frame.applying(transform)
        let length = max(max(rect.width, rect.height), 100)
        rect.size.width = length
        rect.size.height = length
        textBoundingView.frame = rect
        textBoundingView.center = view.convert(center, from: textViewContainer)
    }
    
    private func updateTextDeleteZone(isEnded: Bool) {
        var rect = textBoundingView.frame
        rect.size.width = min(rect.size.width, 100)
        rect.size.height = min(rect.size.height, 100)
        rect.origin.x = textBoundingView.center.x - rect.width * 0.5
        rect.origin.y = textBoundingView.center.y - rect.height * 0.5
        if isEnded {
            delegate?.storyTextEditControllerTextDeleteZoneDidEndUpdate(rect)
        } else {
            delegate?.storyTextEditControllerTextDeleteZoneDidUpdate(rect)
        }
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
    
    @objc private func tapped(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended && textView.isFirstResponder == false {
            textView.becomeFirstResponder()
        }
    }
    
    private var isPanTextView = false
    
    @objc private func panned(_ gesture: UIPanGestureRecognizer) {
        guard isTextGestureEnabled else { return }
        if gesture.state == .began {
            isPanTextView = textView.hasText && (isPanLocatedInTextView() || pan.numberOfTouches > 1)
            if isPanTextView {
                gestureDidBegin()
            } else {
                delegate?.storyTextEditControllerDidPan(pan)
                return
            }
        }
        if gesture.state == .ended {
            gestureDidEnd()
            if isPanTextView {
                updateTextDeleteZone(isEnded: true)
            } else {
                delegate?.storyTextEditControllerDidPan(pan)
            }
            return
        }
        if isPanTextView {
            let translation = gesture.translation(in: view)
            if textTransform == nil {
                textTransform = TextTransform()
                textTransform?.scale = textContainerEditScale
            }
            textTransform?.translation.x += translation.x
            textTransform?.translation.y += translation.y
            gesture.setTranslation(.zero, in: view)
            doTextDisplayTransform()
            updateTextDeleteZone(isEnded: false)
        } else {
            delegate?.storyTextEditControllerDidPan(pan)
        }
    }
    
    @objc private func pinched(_ gesture: UIPinchGestureRecognizer) {
        guard isTextGestureEnabled, textView.hasText else { return }
        switch gesture.state {
        case .began:
            gestureDidBegin()
            fallthrough
        case .changed:
            if textTransform == nil {
                textTransform = TextTransform()
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
        guard isTextGestureEnabled, textView.hasText else { return }
        switch gesture.state {
        case .began:
            gestureDidBegin()
            fallthrough
        case .changed:
            if textTransform == nil {
                textTransform = TextTransform()
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
        delegate?.storyTextEditControllerDidBeginEditing()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.storyTextEidtControllerDidEndEditing()
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
                logger.debug(usedRect)
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

private struct FontSize {
    static let max: CGFloat = 180
    static let min: CGFloat = 20
}
