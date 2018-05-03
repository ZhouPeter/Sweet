//
//  SweetPickerView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol SweetPickerViewDataSource: NSObjectProtocol {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
}

protocol SweetPickerViewDelegate: NSObjectProtocol {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    func done(index: Int)
    func cancel()
}
class SweetPickerView: UIView {
    weak var dataSource: SweetPickerViewDataSource?
    weak var delegate: SweetPickerViewDelegate?
    
    var selectedIndex: Int  = 0 {
        didSet {
            yearsPickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
        }
    }
    private lazy var yearsPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("确定", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonBackgroundView: UIView = {
        let buttonBackgroundView = UIView()
        buttonBackgroundView.backgroundColor = UIColor(hex: 0xF2F2F2)
        return buttonBackgroundView
    }()
    
    @objc private func cancel(_ button: UIButton) {
        delegate?.cancel()
    }

    @objc private func done(_ button: UIButton) {
        delegate?.done(index: yearsPickerView.selectedRow(inComponent: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(yearsPickerView)
        yearsPickerView.fill(in: self, top: 40)
        addSubview(buttonBackgroundView)
        buttonBackgroundView.align(.left, to: self)
        buttonBackgroundView.align(.right, to: self)
        buttonBackgroundView.align(.top, to: self)
        buttonBackgroundView.constrain(height: 40)
        addSubview(doneButton)
        doneButton.align(.right, to: self)
        doneButton.align(.top, to: self)
        doneButton.constrain(width: 50, height: 40)
        addSubview(cancelButton)
        cancelButton.align(.left, to: self)
        cancelButton.align(.top, to: self)
        cancelButton.constrain(width: 50, height: 40)
    }
}

extension SweetPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return dataSource?.pickerView(pickerView, numberOfRowsInComponent: component) ?? 0
    }
    
}
extension SweetPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return delegate?.pickerView(pickerView, titleForRow: row, forComponent: component)
    }
}
