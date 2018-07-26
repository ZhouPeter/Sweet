//
//  UpdateController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol UpdateView: BaseView {
    
}
class UpdateController: BaseViewController, UpdateView {
    
    private var user: UserResponse
    private var updateRemain: UpdateRemainResponse
    init(user: UserResponse, updateRemain: UpdateRemainResponse) {
        self.user = user
        self.updateRemain = updateRemain
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var userViewModels = [UpdateCellViewModel]()
    var schoolViewModels = [UpdateCellViewModel]()
    var loginViewModels = [UpdateCellViewModel]()
    var viewModels = [[UpdateCellViewModel]]()
    private var titles = ["个人资料", "学校信息", "登录方式"]
    private var storage: Storage?
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UpdateTableViewCell.self, forCellReuseIdentifier: "updateCell")
        tableView.register(SweetHeaderView.self, forHeaderFooterViewReuseIdentifier: "updateHeader")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage = Storage(userID: user.userId)
        navigationItem.title = "修改资料"
        view.addSubview(tableView)
        tableView.fill(in: view)
        setViewModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
    }
    deinit {
        writeUserData()
    }
    
    private func writeUserData() {
        let user = self.user
        storage?.write({ (realm) in
            if let userData = realm.object(ofType: UserData.self, forPrimaryKey: Int64(user.userId)) {
                userData.avatarURLString = user.avatar
                userData.nickname = user.nickname
                userData.gender = user.gender.rawValue
                userData.signature = user.signature
                userData.university = user.universityName
                userData.college =  user.collegeName
                userData.enrollment = user.enrollment
                userData.phone = user.phone
                realm.add(userData, update: true)
            }
        })
    }
    
    private func isCanUpdate(updateRemainCount: Int, title: String) -> Bool {
        if updateRemainCount == 0 {
            self.toast(message: "只能修改1次\(title)，当前无法修改")
            return false
        } else if updateRemainCount == 1 {
            return true
        } else {
            return true
        }
    }
    
    // swiftlint:disable function_body_length
    private func setViewModels() {
        let avatarViewModel = UpdateCellViewModel(title: "头像", content: user.avatar) { [weak self] in
            guard let `self` = self else { return }
            guard self.isCanUpdate(updateRemainCount: self.updateRemain.avatar, title: "头像") else { return }
            let controller = UpdateAvatarController(avatar: self.user.avatar)
            controller.saveCompletion = { [weak self] (avatar, remain)in
                self?.updateRemain.avatar = remain!
                self?.user.avatar = avatar
                self?.viewModels[0][0].content = avatar
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        userViewModels.append(avatarViewModel)
        let nameViewModel = UpdateCellViewModel(title: "姓名", content: user.nickname) { [weak self] in
            guard let `self` = self else { return }
            guard self.isCanUpdate(updateRemainCount: self.updateRemain.nickname, title: "姓名") else { return }
            let controller = UpdateNicknameController(nickname: self.user.nickname)
            controller.saveCompletion = { [weak self] (nickname, remain) in
                self?.updateRemain.nickname = remain!
                self?.user.nickname = nickname
                self?.viewModels[0][1].content = nickname
                self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        userViewModels.append(nameViewModel)
        let  genderString = user.gender == .male ? "男生" : "女生"
        let genderViewModel = UpdateCellViewModel(title: "性别", content: genderString) { [weak self] in
            guard let `self` = self else { return }
            guard self.isCanUpdate(updateRemainCount: self.updateRemain.gender, title: "性别") else { return }
            let controller = UpdateGenderController(gender: self.user.gender)
            controller.saveCompletion = { [weak self] (genderString, remain) in
                let gender: Gender = genderString == "男" ? .male : .female
                self?.updateRemain.gender = remain!
                self?.user.gender = gender
                self?.viewModels[0][2].content =  genderString + "生"
                self?.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            }
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        userViewModels.append(genderViewModel)
        let endIndex = user.signature.count > 10 ?
                       user.signature.index(user.signature.startIndex, offsetBy: 10) : user.signature.endIndex
        let range = user.signature.startIndex..<endIndex
        let signatureViewModel = UpdateCellViewModel(
            title: "签名",
            content: String(user.signature[range])) { [weak self] in
            guard let `self` = self else { return }
            guard self.isCanUpdate(updateRemainCount: self.updateRemain.signature, title: "签名") else { return }
            let controller = UpdateSignatureController(signature: self.user.signature)
            controller.saveCompletion = { [weak self] (signature, remain)  in
                self?.updateRemain.signature = remain!
                self?.user.signature = signature
                self?.viewModels[0][3].content = signature
                self?.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
            }
            self.navigationController?.pushViewController(controller, animated: true)
       
        }

        userViewModels.append(signatureViewModel)
        let universityViewModel = UpdateCellViewModel(title: "学校", content: user.universityName) { [weak self] in
            guard let `self` = self else { return }
            guard self.isCanUpdate(updateRemainCount: self.updateRemain.university, title: "学校") else { return }
            let controller = UpdateUniversityController(universityName: self.user.universityName)
            controller.saveCompletion = { (info, remain) in
                let infos = info.split(separator: "#")
                self.updateRemain.university = remain!
                self.user.universityName = String(infos[0])
                self.user.collegeName = String(infos[1])
                self.viewModels[1][0].content = String(infos[0])
                self.viewModels[1][1].content = String(infos[1])
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1),
                                               IndexPath(row: 1, section: 1)],
                                          with: .automatic)
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        schoolViewModels.append(universityViewModel)
        let collegeViewModel = UpdateCellViewModel(title: "学院", content: user.collegeName) { [weak self] in
            guard let `self` = self else { return }
            guard self.isCanUpdate(updateRemainCount: self.updateRemain.college, title: "学院") else { return }
            let controller = UpdateCollegeController(universityName: self.user.universityName)
            controller.saveCompletion = { (info, remain) in
                let infos = info.split(separator: "#")
                self.updateRemain.college = remain!
                self.user.collegeName = String(infos[1])
                self.viewModels[1][1].content = String(infos[1])
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        schoolViewModels.append(collegeViewModel)
        let enrollmentViewModel = UpdateCellViewModel(title: "入学年份", content: "\(user.enrollment)级") { [weak self] in
            guard let `self` = self else { return }
            guard self.isCanUpdate(updateRemainCount: self.updateRemain.enrollment, title: "入学年份") else { return }
            let controller = UpdateEnrollmentController(selectedYear: self.user.enrollment)
            controller.saveCompletion = { (year, remain) in
                self.updateRemain.enrollment = remain!
                self.user.enrollment = Int(year)!
                self.viewModels[1][2].content = "\(year)级"
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .automatic)
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        schoolViewModels.append(enrollmentViewModel)
        
        let phoneViewModel = UpdateCellViewModel(title: "手机", content: user.phone.phoneMiddleHidden()) { [weak self] in
            guard let `self` = self else { return }
            let controller = UpdatePhoneController(phone: self.user.phone)
            controller.saveCompletion = { (phone, _) in
                self.user.phone = phone
                self.viewModels[2][0].content = phone.phoneMiddleHidden()
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        loginViewModels.append(phoneViewModel)
        viewModels.append(userViewModels)
        viewModels.append(schoolViewModels)
        viewModels.append(loginViewModels)
        tableView.reloadData()
    }
}

extension UpdateController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                                    withIdentifier: "updateCell",
                                    for: indexPath) as? UpdateTableViewCell else { fatalError() }

        cell.update(viewModel: viewModels[indexPath.section][indexPath.row])
        return cell
    }
    
}

extension UpdateController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard  let headerView = tableView.dequeueReusableHeaderFooterView(
                                            withIdentifier: "updateHeader") as? SweetHeaderView else { return nil}
        headerView.update(title: titles[section])
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.section][indexPath.row]
        viewModel.callBack?()
    }
    
}
