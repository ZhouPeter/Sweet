//
//  UpdateEnrollmentController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateEnrollmentController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String, Int?) -> Void)?
    
    var selectedYear: Int
    private lazy var years: [Int] = {
        var years = [Int]()
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: Date())
        for year in 1949 ... year {
            years.append(year)
        }
        return years
    }()
    
    private lazy var pickerView: SweetPickerView = {
        let pickerView = SweetPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectedIndex = years.index(of: self.selectedYear)!
        return pickerView
    }()
    
    init(selectedYear: Int) {
        self.selectedYear = selectedYear
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "入学年级"
        view.addSubview(pickerView)
        pickerView.align(.left, to: view)
        pickerView.align(.right, to: view)
        pickerView.align(.bottom, to: view, inset: UIScreen.safeBottomMargin())
        pickerView.constrain(height: 270)

    }

}

extension UpdateEnrollmentController: SweetPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
}

extension UpdateEnrollmentController: SweetPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(years[row])级"
    }
    
    func done(index: Int) {
        web.request(
            .update(updateParameters: ["enrollment": years[index],
                                       "type": UpdateUserType.enrollment.rawValue])) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                let remain = response["remain"] as? Int
                self.saveCompletion?("\(self.years[index])", remain)
                self.navigationController?.popViewController(animated: true)
            case let .failure(error):
                if error.code == WebErrorCode.updateLimit.rawValue {
                    self.toast(message: "修改次数已用完")
                } else {
                    self.toast(message: "修改失败")
                }
                logger.error(error)
            }
            
        }
    }
    
    func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
}
