//
//  EnrollmentViewController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SignUpEnrollmentController: BaseViewController, SignUpEnrollmentView {
    var showSignUpSex: ((RegisterModel) -> Void)?
    var registerModel: RegisterModel!
    var selectCompletion: ((String) -> Void)?
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 0
        tableView.register(EnrollmentTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var yearsPickerView: UIPickerView = {
        let yearsPickerView = UIPickerView()
        yearsPickerView.translatesAutoresizingMaskIntoConstraints = false
        yearsPickerView.delegate = self
        yearsPickerView.dataSource = self
        yearsPickerView.selectRow(years.count - 4 - 1, inComponent: 0, animated: false)
        return yearsPickerView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("确定", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        doneButton.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
        return doneButton
    }()
    private lazy var buttonBackgroundView: UIView = {
        let buttonBackgroundView = UIView()
        buttonBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        buttonBackgroundView.backgroundColor = UIColor(hex: 0xF2F2F2)
        return buttonBackgroundView
    }()
    
    private lazy var years: [Int] = {
        var years = [Int]()
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: Date())
        for year in 1949 ... year {
            years.append(year)
        }
        return years
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "选择入学年份"
        self.navigationController?.navigationBar.barTintColor = UIColor.xpYellow()
        setTableView()
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.fill(in: view)
    }
    
    private func addYearsPickerView() {
        view.addSubview(yearsPickerView)
        yearsPickerView.align(.left, to: view)
        yearsPickerView.align(.right, to: view)
        yearsPickerView.align(.bottom, to: view, inset: UIScreen.isIphoneX() ? 34 : 0)
        yearsPickerView.constrain(height: 230)
        view.addSubview(buttonBackgroundView)
        buttonBackgroundView.align(.left, to: view)
        buttonBackgroundView.align(.right, to: view)
        buttonBackgroundView.pin(to: yearsPickerView, edge: .top)
        buttonBackgroundView.constrain(height: 40)
        buttonBackgroundView.addSubview(cancelButton)
        cancelButton.align(.left, to: buttonBackgroundView)
        cancelButton.align(.top, to: buttonBackgroundView)
        cancelButton.align(.bottom, to: buttonBackgroundView)
        doneButton.constrain(width: 50)
        buttonBackgroundView.addSubview(doneButton)
        doneButton.align(.right, to: buttonBackgroundView)
        doneButton.align(.top, to: buttonBackgroundView)
        doneButton.align(.bottom, to: buttonBackgroundView)
        cancelButton.constrain(width: 50)
    
    }
}

extension SignUpEnrollmentController {
    @objc private func done(_ sender: UIButton) {
        yearsPickerView.removeFromSuperview()
        buttonBackgroundView.removeFromSuperview()
        registerModel?.enrollment = years[yearsPickerView.selectedRow(inComponent: 0)]
        showSignUpSex?(registerModel)
    }
    
    @objc private func cancel(_ sender: UIButton) {
        yearsPickerView.removeFromSuperview()
        buttonBackgroundView.removeFromSuperview()
    }

}

extension SignUpEnrollmentController: UIPickerViewDelegate {
    
}
extension SignUpEnrollmentController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(years[row])级"
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
}

extension SignUpEnrollmentController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            as? EnrollmentTableViewCell else {  fatalError() }
        if indexPath.row < 4 {
            cell.updateWithText("\(years[years.count - 4 + indexPath.row])级")
        } else {
            cell.updateWithText("其他")
        }
        return cell
    }
}

extension SignUpEnrollmentController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < 4 {
            registerModel.enrollment = years[years.count - 4 + indexPath.row]
            showSignUpSex?(registerModel)
        } else {
            addYearsPickerView()
        }
    }
}
