//
//  InputTextView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/16.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class GrowingTextView: UITextView {
    var maxLength: Int
    var maxHeight: CGFloat
    var trimWhiteSpaceWhenEndEditing: Bool
    var placeholder: String {
        didSet {
            setNeedsDisplay()
        }
    }
    var placeholderColor: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }
    var placeholderLeftMargin: CGFloat {
        didSet {
            setNeedsDisplay()
        }
    }
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.origin.x -= placeholder.boundingSize(font: font!,
                                                  size: CGSize(width: bounds.width,
                                                               height: CGFloat.greatestFiniteMagnitude)).width / 2
        return rect
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        maxHeight = 0
        maxLength = 0
        trimWhiteSpaceWhenEndEditing = true
        placeholder = ""
        placeholderColor = UIColor(white: 0.8, alpha: 1)
        placeholderLeftMargin = 0
        super.init(frame: frame, textContainer: textContainer)
        contentMode = .redraw
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange(note:)),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidEndEditing(note:)),
                                               name: NSNotification.Name.UITextViewTextDidEndEditing,
                                               object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 30)
    }

    func currentHeight() -> CGFloat {
        let size = sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return maxHeight > 0 ? min(size.height, maxHeight) : size.height
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        let placeholderRect = CGRect(x: textContainerInset.left + placeholderLeftMargin,
                                     y: textContainerInset.top,
                                     width: frame.width - textContainerInset.left - textContainerInset.right,
                                     height: frame.height)
        var attributes = [NSAttributedStringKey.foregroundColor: placeholderColor,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle]
        if let font = font {
            attributes[NSAttributedStringKey.font] = font
        }
        (self.placeholder as NSString).draw(in: placeholderRect, withAttributes: attributes)
    }
    
    @objc private func textDidEndEditing(note: Notification) {
        if let textView = note.object as? GrowingTextView, textView != self {
            return
        }
        text = text.trimmingCharacters(in: NSCharacterSet.whitespaces)
        setNeedsDisplay()
    }
    
    @objc private func textDidChange(note: Notification) {
        if let textView = note.object as? GrowingTextView, textView != self {
            return
        }
        if maxLength > 0 && text.count > maxLength {
            let endIndex = text.index(text.startIndex, offsetBy: maxLength)
            text = String(text[...endIndex])
            undoManager?.removeAllActions()
        }
        setNeedsDisplay()
    }
    
}

protocol InputTextViewDelegate: NSObjectProtocol {
    func inputTextViewDidPressSendMessage(text: String)
    func removeInputTextView()
}
class InputTextView: UIView {
    var placehoder: String = "" {
        didSet {
            textView.placeholder = placehoder
        }
    }
    weak var delegate: InputTextViewDelegate?
    var textToken: NSKeyValueObservation?
    private lazy var blackMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var textView: GrowingTextView = {
        let textView = GrowingTextView()
        textView.placeholder = placehoder
        textView.placeholderColor = .white
        textView.tintColor = textView.placeholderColor
        textView.placeholderLeftMargin = 5
        textView.maxHeight = 200
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.textColor = .white
        textView.font = UIFont.boldSystemFont(ofSize: 30)
        textView.isScrollEnabled = true
        textView.textAlignment = .center
        return textView
    }()

    private lazy var senderButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Like"), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        return button
    }()
    private let keyboardObserver = KeyboardObserver()
    private var senderButtonBottomConstraint: NSLayoutConstraint?
    private var downPan: CustomPanGestureRecognizer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        keyboardObserver.observe { [weak self] in self?.handleKeyboardEvent($0) }
        textToken = textView.observe(\.text, options: [.new], changeHandler: { (textView, _) in
            self.setPlaceholder(isHidden: textView.text != "")
            self.contentSizeToFit()
        })
        downPan = CustomPanGestureRecognizer(orientation: .down, target: self, action: #selector(downPanAction(_:)))
        addGestureRecognizer(downPan)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        textToken?.invalidate()
    }
    private func contentSizeToFit() {
        var contentSize = textView.contentSize
        var offset: UIEdgeInsets
        var newSize: CGSize
        if contentSize.height <= textView.bounds.height {
            let font = UIFont.boldSystemFont(ofSize: 30)
            textView.font = font
            let offsetY = (textView.bounds.height - textView.contentSize.height) / 2
            offset = UIEdgeInsets(top: offsetY, left: 0, bottom: 0, right: 0)
            newSize = contentSize
        } else {
            newSize = textView.bounds.size
            offset = .zero
            var fontSize = 30
            while contentSize.height > textView.bounds.height {
                fontSize -= 1
                let font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
                textView.font = font
                contentSize = textView.text.boundingSize(font: textView.font!,
                                                         size: CGSize(width: textView.bounds.width,
                                                                      height: CGFloat.greatestFiniteMagnitude))
            }
            newSize = contentSize
        }
        textView.contentSize = newSize
        textView.contentInset = offset
    }

    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            let keyboardHeight = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
            self.senderButtonBottomConstraint?.constant = -(keyboardHeight + 10)
            self.contentSizeToFit()
            UIView.animate(
                withDuration: event.duration,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: UInt(event.curve.rawValue)),
                animations: {
                    self.layoutIfNeeded()
            }, completion: nil)

        default:
            break
        }
    }
    
    private func setPlaceholder(isHidden: Bool) {
        if isHidden {
            textView.placeholder = ""
        } else {
            textView.placeholder = placehoder
        }
    }
    
    private func setupUI() {
        addSubview(blackMaskView)
        blackMaskView.fill(in: self)
        addSubview(senderButton)
        senderButton.constrain(width: 80, height: 40)
        senderButton.centerX(to: self)
        senderButtonBottomConstraint = senderButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        senderButtonBottomConstraint?.isActive = true
        senderButton.setViewRounded()
        addSubview(cancelButton)
        cancelButton.constrain(width: 40, height: 40)
        cancelButton.centerY(to: senderButton)
        cancelButton.align(.right, to: self, inset: 20)
        addSubview(textView)
        textView.align(.right, to: self, inset: 10)
        textView.align(.left, to: self, inset: 10)
        textView.align(.top, to: self, inset: UIScreen.isIphoneX() ? 24 + 15 : 15)
        textView.pin(.top, to: senderButton, spacing: 10)
      
    }
   
}
// MARK: - Open Methods
extension InputTextView {
    
    func clear() {
        textView.font = UIFont.boldSystemFont(ofSize: 30)
        textView.text = nil
    }
    
    func startEditing(isStarted: Bool) {
        if isStarted {
            self.textView.becomeFirstResponder()
        } else {
            textView.font = UIFont.boldSystemFont(ofSize: 30)
            textView.text = nil
            textView.endEditing(true)
        }
    }
}

extension InputTextView {
    @objc private func sendAction(_ sender: UIButton) {
        delegate?.inputTextViewDidPressSendMessage(text: textView.text)
    }
    @objc private func cancelAction(_ sender: UIButton) {
        delegate?.removeInputTextView()
    }
    
    @objc private func downPanAction(_ gesture: CustomPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let progress = translation.y / bounds.height
        switch gesture.state {
        case .began: break
        case .changed: break
        default:
            if progress + gesture.velocity(in: nil).y / bounds.height > 0.3 {
                delegate?.removeInputTextView()
            }
        }
    }
}

extension InputTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        setPlaceholder(isHidden: textView.text != "")
        contentSizeToFit()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}
