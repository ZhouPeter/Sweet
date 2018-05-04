//
//  StoryTextEditController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class StoryTextEditController: UIViewController {
    
    private lazy var textView: UITextView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = .clear
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 30)
        view.textAlignment = .center
        view.delegate = self
        view.keyboardDismissMode = .interactive
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))))
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
    
    private let keyboard = KeyboardObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(placeholderLabel)
        placeholderLabel.center(to: view)
        view.addSubview(textView)
        textView.align(.left, to: view, inset: 20)
        textView.align(.right, to: view, inset: 20)
        textView.align(.bottom, to: view, inset: 20)
        textView.align(.top, to: view, inset: 40)
        
        keyboard.observe { [weak self] in self?.handleKeyboardEvent($0) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustContentSize(with: textView)
    }
    
    // MARK: - Private
    
    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            let distance = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
            let bottom = distance >= bottomLayoutGuide.length ? distance : bottomLayoutGuide.length
            UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                self.textView.contentInset.bottom = bottom
                self.textView.scrollIndicatorInsets.bottom = bottom
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
        var typingLineString = ""
        layoutManager.enumerateLineFragments(forGlyphRange: layoutRange) { (_, _, _, glyphRange, stop) in
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let string = (textView.text as NSString).substring(with: characterRange)
            if NSLocationInRange(range.location, glyphRange) {
                typingLineString = string
                stop.pointee = true
            } else if range.location == layoutRange.length {
                typingLineString = string
            }
        }
        let fontSize = calculateFontSize(with: typingLineString)
        var typingAttributes = textView.typingAttributes
        typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont.systemFont(ofSize: fontSize)
        textView.typingAttributes = typingAttributes
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        var lineRanges = [NSRange]()
        let layoutManager = textView.layoutManager
        let range = NSRange(location: 0, length: layoutManager.numberOfGlyphs)
        layoutManager.enumerateLineFragments(forGlyphRange: range) { (_, _, _, glyphRange, _) in
            lineRanges.append(layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil))
        }
        let textStorage = textView.textStorage
        textStorage.beginEditing()
        lineRanges.forEach { (range) in
            let string = (textView.text as NSString).substring(with: range)
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
        
        UIView.animate(withDuration: 0.25) {
            self.placeholderLabel.alpha = textView.hasText ? 0 : 1
        }
        adjustContentSize(with: textView)
    }
    
    private func calculateFontSize(with string: String) -> CGFloat {
        let maxSize: CGFloat = 180
        let minSize: CGFloat = 40
        guard string.count > 1 else { return maxSize }
        let fontSize = maxSize
        let attributedString = NSAttributedString(
            string: string,
            attributes: [.font: UIFont.systemFont(ofSize: fontSize)]
        )
        let textWidth = attributedString.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [],
            context: nil
            ).width
        let scaleFactor = 200 / textWidth
        let preferredFontSize = fontSize * scaleFactor
        let size = min(max(minSize, preferredFontSize), maxSize)
        return size
    }
    
    private func adjustContentSize(with textView: UITextView) {
        let deadSpace = textView.bounds.size.height - textView.contentSize.height
        let inset = max(0, deadSpace/2.0)
        textView.contentInset = UIEdgeInsets(
            top: inset,
            left: textView.contentInset.left,
            bottom: inset,
            right: textView.contentInset.right
        )
    }
}
