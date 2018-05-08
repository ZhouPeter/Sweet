//
//  StoryTextEditController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

private struct FontSize {
    static let max: CGFloat = 180
    static let min: CGFloat = 30
}

final class StoryTextEditController: UIViewController {
    private let topInset: CGFloat = 20
    private let leftInset: CGFloat = 20
    private let rightInset: CGFloat = 20
    private let bottomInset: CGFloat = 50
    
    private let textViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))))
        return view
    } ()
    
    private lazy var textView: UITextView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = .clear
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: FontSize.max)
        view.textAlignment = .center
        view.delegate = self
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))))
        view.textContainerInset = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "输入文字内容..."
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: FontSize.min)
        return label
    } ()
    
    private let keyboard = KeyboardObserver()
    private var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(placeholderLabel)
        placeholderLabel.center(to: view)
        
        view.addSubview(textViewContainer)
        textViewContainer.addSubview(textView)
        
        layoutTextContainer()
        textView.frame.size.width = textViewContainer.frame.width
        textView.frame.origin.x = 0
        layoutTextView()
        
        keyboard.observe { [weak self] in self?.handleKeyboardEvent($0) }
    }
    
    // MARK: - Private
    
    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            keyboardHeight = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
            UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                self.layoutTextContainer()
                self.layoutTextView()
            }, completion: nil)
        default:
            break
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
        let height = textView.hasText ? textView.contentSize.height : 200
        // fix content size error
        return ceil(textView.sizeThatFits(CGSize(width: textView.frame.width, height: height)).height)
    }
    
    private func layoutTextView() {
        let textHeight = safeTextHeight
        let containerHeight = textContainerHeight
        var transform = CATransform3DIdentity
        if textHeight > containerHeight {
            let scale = containerHeight / textHeight
            transform = CATransform3DMakeScale(scale, scale, 1)
        }
        textViewContainer.layer.sublayerTransform = transform
        var frame = textView.frame
        frame.origin.y = ceil((containerHeight - textHeight) * 0.5)
        frame.size.height = textHeight
        textView.frame = frame
        // fix content offset error
        textView.setContentOffset(.zero, animated: false)
        textView.setContentOffset(.zero, animated: true)
    }
    
    // MARK: - Actionsa
    
    private var panStart: CGPoint?
    
    @objc private func panned(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        switch gesture.state {
        case .began:
            panStart = location
        case .changed:
            guard let start = panStart else { return }
            let threshold: CGFloat = 5
            let distanceX = location.x - start.x
            let distanceY = location.y - start.y
            guard abs(distanceX) > threshold, abs(distanceY) > threshold else { return }
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
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
        placeholderLabel.alpha = textView.hasText ? 0 : 1
        layoutTextView()
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
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
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
