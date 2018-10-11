//
//  UpdateConstellationController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/10/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateConstellationController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String, Int?) -> Void)?
    
    private var constellationList: [Constellation] =
    [
      Constellation(name: "水瓶座", date: "01.20~02.18"),
      Constellation(name: "双鱼座", date: "02.19~03.20"),
      Constellation(name: "白羊座", date: "03.21~04.19"),
      Constellation(name: "金牛座", date: "04.20~05.20"),
      Constellation(name: "双子座", date: "05.21~06.21"),
      Constellation(name: "巨蟹座", date: "06.22~07.22"),
      Constellation(name: "狮子座", date: "07.23~08.22"),
      Constellation(name: "处女座", date: "08.23~09.22"),
      Constellation(name: "天秤座", date: "09.23~10.23"),
      Constellation(name: "天蝎座", date: "10.24~11.22"),
      Constellation(name: "射手座", date: "11.23~12.21"),
      Constellation(name: "摩羯座", date: "12.22~01.19"),
    ]
    private var selectedConstellationIndex: Int?
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConstellationCell.self, forCellReuseIdentifier: "ConstellationCell")
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.xpGray()
        return tableView
    }()
    
    init(constellationName: String) {
        if constellationName != "" {
            selectedConstellationIndex = constellationList.firstIndex(where: { $0.name == constellationName} )
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpGray()
        navigationItem.title = "选择星座"
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.fill(in: view, top: UIScreen.navBarHeight() + 10)
    }

}

extension UpdateConstellationController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        web.request(
            .update(updateParameters: ["zodiac": constellationList[indexPath.row].name,
                                       "type": UpdateUserType.zodiac.rawValue])
        ) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                let remain = response["remain"] as? Int
                self.saveCompletion?(self.constellationList[indexPath.row].name, remain)
                self.selectedConstellationIndex = indexPath.row
                tableView.reloadData()
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
}

extension UpdateConstellationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return constellationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "ConstellationCell",
                    for: indexPath) as? ConstellationCell else { fatalError() }
        cell.updateWith(constellationList[indexPath.row],
                        isSelected: selectedConstellationIndex == nil ? false : indexPath.row == selectedConstellationIndex! )
        return cell
    }
    
    
}
