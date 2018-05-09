//
//  StoryTextEditController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable file_length

import UIKit

private struct FontSize {
    static let max: CGFloat = 180
    static let min: CGFloat = 20
}

private struct TextTransform {
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
    var translation = CGPoint.zero
    
    func make3DTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
        transform = CATransform3DRotate(transform, rotation, 0, 0, 1)
        transform = CATransform3DScale(transform, scale, scale, 1)
        return transform
    }
}

final class StoryTextEditController: UIViewController {
    private let topInset: CGFloat = 20
    private let leftInset: CGFloat = 20
    private let rightInset: CGFloat = 20
    private let bottomInset: CGFloat = 50
    
    private lazy var textViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinched(_:)))
        pinch.delegate = self
        view.addGestureRecognizer(pinch)
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotated(_:)))
        rotation.delegate = self
        view.addGestureRecognizer(rotation)
        return view
    } ()
    
    private var panStart: CGPoint?
    private var isTextGestureEnabled = false
    private var textContainerEditScale: CGFloat = 1
    private var textTransform: TextTransform?
    
    private lazy var textView: UITextView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = .clear
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: FontSize.max)
        view.textAlignment = self.paragraphStyle.alignment
        view.delegate = self
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))))
        view.textContainerInset = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = self.paragraphStyle.alignment
        label.text = "输入文字内容..."
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: FontSize.min)
        return label
    } ()
    
    private let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    } ()
    
    private let keyboard = KeyboardObserver()
    private var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(placeholderLabel)
        
        view.addSubview(textViewContainer)
        textViewContainer.addSubview(textView)
        placeholderLabel.center(to: textViewContainer)
        
        layoutTextContainer()
        textView.frame.size.width = textViewContainer.frame.width
        textView.frame.origin.x = 0
        layoutTextView()
        updateTextEditTransform(animated: false)
        
        keyboard.observe { [weak self] in self?.handleKeyboardEvent($0) }
    }
    
    // MARK: - Private
    
    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            keyboardHeight = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
            UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                if self.textView.hasText {
                    self.placeholderLabel.alpha = 0
                } else {
                    self.placeholderLabel.alpha = self.keyboardHeight > 0 ? 0 : 1
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
            isTextGestureEnabled = true
            doTextDisplayTransform()
        }
    }
    
    private func layoutTextContainer() {
        let width = view.bounds.width
        let containerWidth = width - leftInset - rightInset
        textViewContainer.frame = CGRect(
            x: leftInset,
            y: topInset,
            width: containerWidth,
            height: textContainerHeight
        )
    }
    
    private var textContainerHeight: CGFloat {
        return view.bounds.height - keyboardHeight - topInset - bottomInset
    }
    
    private var safeTextHeight: CGFloat {
        let height = textView.hasText ? textView.contentSize.height : FontSize.min
        // fix content size error
        return ceil(textView.sizeThatFits(CGSize(width: textView.frame.width, height: height)).height)
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
    
    // MARK: - Actions
    
    @objc private func tapped(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended && textView.isFirstResponder == false {
            textView.becomeFirstResponder()
        }
    }
    
    private var isPanForKeyboard = false
    
    @objc private func panned(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPanForKeyboard = textView.isFirstResponder
        case .ended, .cancelled:
            isPanForKeyboard = textView.isFirstResponder
        default:
            break
        }
        if isPanForKeyboard {
            handlePanKeyboardGesture(gesture)
        } else {
            handlePanTextGesture(gesture)
        }
    }
    
    private func handlePanKeyboardGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        switch gesture.state {
        case .began:
            panStart = location
        case .changed:
            guard let start = panStart else { return }
            let threshold: CGFloat = 5
            let distanceX = location.x - start.x
            let distanceY = location.y - start.y
            guard abs(distanceY) > threshold else { return }
            let tangent = distanceX / distanceY
            let isVertical = tangent >= -1 && tangent <= 1
            if isVertical {
                let isDown = location.y > start.y
                if isDown == false { return }
                textView.resignFirstResponder()
            }
        default:
            break
        }
    }

    private func handlePanTextGesture(_ gesture: UIPanGestureRecognizer) {
        guard isTextGestureEnabled else { return }
        switch gesture.state {
        case .began, .changed:
            let translation = gesture.translation(in: view)
            if textTransform == nil {
                textTransform = TextTransform()
                textTransform?.scale = textContainerEditScale
            }
            textTransform?.translation.x += translation.x * 0.5
            textTransform?.translation.y += translation.y * 0.5
            gesture.setTranslation(.zero, in: view)
            doTextDisplayTransform()
        default:
            break
        }
    }
    
    @objc private func pinched(_ gesture: UIPinchGestureRecognizer) {
        guard isTextGestureEnabled else { return }
        switch gesture.state {
        case .began, .changed:
            if textTransform == nil {
                textTransform = TextTransform()
                textTransform?.scale = textContainerEditScale
            }
            textTransform?.scale *= gesture.scale
            gesture.scale = 1
            doTextDisplayTransform()
        default:
            break
        }
    }
    
    @objc private func rotated(_ gesture: UIRotationGestureRecognizer) {
        guard isTextGestureEnabled else { return }
        switch gesture.state {
        case .began, .changed:
            if textTransform == nil {
                textTransform = TextTransform()
                textTransform?.scale = textContainerEditScale
            }
            textTransform?.rotation += gesture.rotation
            gesture.rotation = 0
            doTextDisplayTransform()
        default:
            break
        }
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
        layoutManager.enumerateLineFragments(forGlyphRange: range) { (_, _, _, glyphRange, _) in
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
