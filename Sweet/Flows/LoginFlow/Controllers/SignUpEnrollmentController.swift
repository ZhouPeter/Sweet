//
//  EnrollmentViewController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SignUpEnrollmentController: BaseViewController, SignUpEnrollmentView {
    var showSignUpSex: ((LoginRequestBody) -> Void)?
    var loginRequestBody: LoginRequestBody!
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
    
    private lazy var yearsPickerView: SweetPickerView = {
        let pickerView = SweetPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectedIndex = years.count - 5
        return pickerView
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
        yearsPickerView.constrain(height: 270)
    }
}

extension SignUpEnrollmentController: SweetPickerViewDelegate {
   func done(index: Int) {
        yearsPickerView.removeFromSuperview()
        loginRequestBody?.enrollment = years[index]
        showSignUpSex?(loginRequestBody)
    }
    
    func cancel() {
        yearsPickerView.removeFromSuperview()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(years[row])级"
    }
}

extension SignUpEnrollmentController: SweetPickerViewDataSource {
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
            loginRequestBody.enrollment = years[years.count - 4 + indexPath.row]
            showSignUpSex?(loginRequestBody)
        } else {
            addYearsPickerView()
        }
    }
}
