//
//  UpdateSettingsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateSettingsController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UpdateSettingTableViewCell.self, forCellReuseIdentifier: "settingCell")
        tableView.register(SweetHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        return tableView
    }()
    private var titles = ["播放设置", "通知设置"]
    private var dataSource: [(String, Bool)] {
       return [("使用移动网络时，自动播放视频", setting.autoPlay), ("通知显示消息详情", setting.showMsg)]
    }
    private var setting: UserSetting
    private var storage: Storage?
    init(setting: UserSetting) {
        self.setting = setting
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.fill(in: view)
        navigationItem.title = "系统设置"
        storage = Storage(userID: setting.userId)
    }
    
    private func writeUserSetting() {
        storage?.write({ (realm) in
            if let settingData = realm.object(ofType: SettingData.self, forPrimaryKey: Int64(self.setting.userId)) {
                settingData.autoPlay = self.setting.autoPlay
                settingData.showMsg = self.setting.showMsg
                realm.add(settingData, update: true)
            }
        })
    }
    private func updateSetting(setting: UserSetting) {
        web.request(
            .updateSetting(autoPlay: setting.autoPlay,
                           showMsg: setting.showMsg)
        ) { (result) in
            switch result {
            case .success:
                self.setting = setting
                self.writeUserSetting()
                self.tableView.reloadData()
            case .failure: break
            }
        }
    }
    
}

extension UpdateSettingsController: UpdateSettingTableViewCellDelegate {
    func changeSetting(isOn: Bool, cell: UpdateSettingTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            if indexPath.section == 0 {
                let setting = UserSetting(userId: self.setting.userId, autoPlay: isOn, showMsg: self.setting.showMsg)
                updateSetting(setting: setting)
            } else if indexPath.section == 1 {
                let setting = UserSetting(userId: self.setting.userId, autoPlay: self.setting.autoPlay, showMsg: isOn)
                updateSetting(setting: setting)
            }
        }
    }
}

extension UpdateSettingsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "settingCell",
            for: indexPath) as? UpdateSettingTableViewCell else { fatalError() }
        cell.update(description: dataSource[indexPath.section].0, isOpen: dataSource[indexPath.section].1)
        cell.delegate = self
        return cell
    }
}

extension UpdateSettingsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? SweetHeaderView
        header?.update(title: titles[section])
        return header
    }

}
