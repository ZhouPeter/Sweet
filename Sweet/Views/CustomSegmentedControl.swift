//
//  CustomSegmentedControl.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl {
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        return view
    }()
    
    private var bottomViewLeftConstraint: NSLayoutConstraint?
    private var token: NSKeyValueObservation?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        tintColor = .clear
        let normalTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                                    NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        setTitleTextAttributes(normalTextAttributes, for: .normal)
        let selectedTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                                      NSAttributedStringKey.foregroundColor: UIColor.white]
        setTitleTextAttributes(selectedTextAttributes, for: .selected)
        selectedSegmentIndex = 0
        addSubview(bottomView)
        bottomView.constrain(width: 10, height: 2)
        bottomView.align(.bottom)
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        bottomViewLeftConstraint = bottomView.align(
            .left, inset: segmentWidth * CGFloat(selectedSegmentIndex + 1) - segmentWidth / 2 - 5)
        token = self.observe(\.selectedSegmentIndex, options: [.new, .old]) { (control, change) in
            if change.newValue == change.oldValue { return }
            let selectedSegmentIndex = control.selectedSegmentIndex
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomViewLeftConstraint?.constant =
                            segmentWidth * CGFloat(selectedSegmentIndex + 1) - segmentWidth / 2 - 5
            })
            
        }
        
    }
    
    deinit {
        token?.invalidate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
