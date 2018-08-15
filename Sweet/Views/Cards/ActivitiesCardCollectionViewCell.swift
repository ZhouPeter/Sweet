//
//  ActivitiesCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ActivitiesCardCollectionViewCellDelegate: BaseCardCollectionViewCellDelegate {
    func showWebController(url: String, content: String)
}
class ActivitiesCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    private var viewModel: ViewModelType?
    typealias ViewModelType = ActivitiesCardViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 70
        tableView.separatorInset.right = 10
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AcitivityCardTableViewCell.self, forCellReuseIdentifier: "activityCell")
        tableView.separatorColor = UIColor(hex: 0xf2f2f2)
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        customContent.addSubview(tableView)
        tableView.fill(in: customContent, top: 50)
        tableView.setViewRounded(cornerRadius: 10, corners: .allCorners)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(_ viewModel: ActivitiesCardViewModel) {
        self.cardId = viewModel.cardId
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.titleString
        tableView.reloadData()
    }
    
    func updateItem(item: Int, like: Bool) {
        let cell = tableView.cellForRow(at: IndexPath(row: item, section: 0))
        if let cell = cell as? AcitivityCardTableViewCell {
            cell.update(like: like)
        }
    }
}

extension ActivitiesCardCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.activityViewModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
              withIdentifier: "activityCell",
              for: indexPath) as? AcitivityCardTableViewCell else { fatalError() }
        if let feedViewModel = viewModel?.activityViewModels[indexPath.row] {
            cell.update(feedViewModel)
            if indexPath.row == 3 {
                cell.separatorInset.left = UIScreen.mainWidth()
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            }
        }
        return cell
    }
}

extension ActivitiesCardCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel!.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  let feedViewModel = viewModel?.activityViewModels[indexPath.row] {
            feedViewModel.showProfile?(feedViewModel.actor, feedViewModel.setTop)
        }
    }
}
