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
    static let min: CGFloat = 40
}

final class StoryTextEditController: UIViewController {
    private lazy var textView: UITextView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = .clear
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: FontSize.max)
        view.textAlignment = .center
        view.delegate = self
        view.keyboardDismissMode = .interactive
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))))
        view.backgroundColor = .brown
        view.textContainerInset = .zero
        return view
    } ()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "输入文字内容..."
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    } ()
    
    private var textViewBottom: NSLayoutConstraint?
    
    private let keyboard = KeyboardObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(placeholderLabel)
        placeholderLabel.center(to: view)
        view.addSubview(textView)
        textView.align(.left, to: view, inset: 20)
        textView.align(.right, to: view, inset: 20)
        textView.align(.top, to: view, inset: 50)
        textViewBottom = textView.align(.bottom, to: view, inset: 20)
        
        keyboard.observe { [weak self] in self?.handleKeyboardEvent($0) }
    }
    
    // MARK: - Private
    
    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            let distance = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
            let bottom = distance >= bottomLayoutGuide.length ? distance : bottomLayoutGuide.length
            textViewBottom?.constant = -(bottom + 20)
            UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        default:
            break
        }
    }
    
    // MARK: - Actions
    
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
        var fontSize = FontSize.max
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        layoutManager.enumerateLineFragments(forGlyphRange: layoutRange) { (_, _, _, glyphRange, stop) in
            var isTypingLine = false
            if range.length == 0 {
                // insert
                if range.location == glyphRange.location + glyphRange.length {
                    isTypingLine = true
                } else if NSLocationInRange(range.location, glyphRange) {
                    isTypingLine = true
                }
            } else {
                // delete
                if NSLocationInRange(range.location, glyphRange) {
                    isTypingLine = true
                }
            }
            guard isTypingLine else { return }
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let string = (textView.text as NSString).substring(with: characterRange)
            let newRange = NSRange(location: range.location - glyphRange.location, length: 0)
            let typingLineString = (string as NSString).replacingCharacters(in: newRange, with: text)
            stop.pointee = true
            let textStorage = textView.textStorage
            textStorage.beginEditing()
            fontSize = self.calculateFontSize(with: typingLineString)
            textStorage.setAttributes(
                [
                    .font: UIFont.systemFont(ofSize: fontSize),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraphStyle
                ],
                range: characterRange
            )
            textStorage.endEditing()
        }
        
        var typingAttributes = textView.typingAttributes
        typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont.systemFont(ofSize: fontSize)
        textView.typingAttributes = typingAttributes
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextStorageFontSize()
        UIView.animate(withDuration: 0.25) {
            self.placeholderLabel.alpha = textView.hasText ? 0 : 1
        }
    }
    
    private func adjustTextStorageFontSize() {
        let layoutManager = textView.layoutManager
        let range = NSRange(location: 0, length: layoutManager.numberOfGlyphs)
        let textStorage = textView.textStorage
        textStorage.beginEditing()
        layoutManager.enumerateLineFragments(forGlyphRange: range) { (_, _, _, glyphRange, _) in
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let string = (self.textView.text as NSString).substring(with: characterRange)
            let fontSize = self.calculateFontSize(with: string)
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
        let textContainerWidth = textView.bounds.width - FontSize.min
        let scaleFactor = textContainerWidth / textWidth
        let preferredFontSize = fontSize * scaleFactor
        return min(max(FontSize.min, preferredFontSize), FontSize.max)
    }
}
